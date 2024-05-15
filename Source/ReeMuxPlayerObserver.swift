//
//  ReeMuxPlayerObserver.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

import AVKit

protocol ReeMuxPlayerObserverProtocol {
    func addTimeObserver(toPlayer player: AVPlayer)
    func removeTimeObserver(fromPlayer player: AVPlayer)
    func addTimeControlStatusObserver(toPlayer player: AVPlayer)
    func removeTimeControlStatusObserver(fromPlayer player: AVPlayer)
    func addStatusObserver(toPlayerItem playerItem: AVPlayerItem)
    func removeStatusObserver(toPlayerItem playerItem: AVPlayerItem)
    func addPlayerReachEndObserver(toPlayerItem playerItem: AVPlayerItem)
    func removePlayerReachEndObserver(toPlayerItem playerItem: AVPlayerItem)
}

protocol ReeMuxPlayerObserverDelegate {
    func didCurrentTimeChange(currentTimeInMilliSeconds: Double)
    func didTimeControlStatusChange(oldStatus: AVPlayer.TimeControlStatus?, newStatus: AVPlayer.TimeControlStatus?)
    func didStatusChange(status: AVPlayerItem.Status)
    func didPlayerReachEnd()
}

class ReeMuxPlayerObserver: NSObject, ReeMuxPlayerObserverProtocol {
    // MARK: Variables

    static let kTimeControlStatus = "timeControlStatus"
    static let kStatus = "status"

    var delegate: ReeMuxPlayerObserverDelegate?

    private var currentTimeObserver: Any?
    private var playerReachEndObserver: Any?

    private var timeControlStatusContext = 0
    private var isTimeControlStatusContextEnabled = false

    private var statusContext = 1
    private var isStatusContextEnabled = false

    // MARK: Life Cycle

    override init() {
        super.init()
    }

    deinit {
        print("ReeMuxPlayerObserver: deinit")
    }

    // MARK: Methods

    private func didCurrentTimeChange(time: CMTime) {
        let currentTimeInMilliSeconds = time.seconds * 1000
        //            logger.info("Time: \(currentTimeInMilliSeconds)")
        delegate?.didCurrentTimeChange(currentTimeInMilliSeconds: currentTimeInMilliSeconds)
    }

    func didPlayerReachEnd(notification: Notification) {
        delegate?.didPlayerReachEnd()
    }

    // MARK: Protocol Methods

    func addTimeObserver(toPlayer player: AVPlayer) {
        currentTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: nil, using: didCurrentTimeChange)
    }

    func removeTimeObserver(fromPlayer player: AVPlayer) {
        if let currentTimeObserver {
            player.removeTimeObserver(currentTimeObserver)
        }

        currentTimeObserver = nil
    }

    func addTimeControlStatusObserver(toPlayer player: AVPlayer) {
        player.addObserver(self, forKeyPath: ReeMuxPlayerObserver.kTimeControlStatus, options: [.new, .old], context: &timeControlStatusContext)
        isTimeControlStatusContextEnabled = true
    }

    func removeTimeControlStatusObserver(fromPlayer player: AVPlayer) {
        guard isTimeControlStatusContextEnabled else { return }
        player.removeObserver(self, forKeyPath: ReeMuxPlayerObserver.kTimeControlStatus, context: &timeControlStatusContext)
        isTimeControlStatusContextEnabled = false
    }

    func addStatusObserver(toPlayerItem playerItem: AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: ReeMuxPlayerObserver.kStatus, options: [.new, .old], context: &statusContext)
        isStatusContextEnabled = true
    }

    func removeStatusObserver(toPlayerItem playerItem: AVPlayerItem) {
        guard isStatusContextEnabled else { return }
        playerItem.removeObserver(self, forKeyPath: ReeMuxPlayerObserver.kStatus, context: &statusContext)
        isStatusContextEnabled = false
    }

    func addPlayerReachEndObserver(toPlayerItem playerItem: AVPlayerItem) {
        playerReachEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main, using: didPlayerReachEnd)
    }

    func removePlayerReachEndObserver(toPlayerItem playerItem: AVPlayerItem) {
        if let playerReachEndObserver {
            NotificationCenter.default.removeObserver(playerReachEndObserver)
        }
        playerReachEndObserver = nil
    }

    // MARK: KVO Methods

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case ReeMuxPlayerObserver.kTimeControlStatus:
            if context == &timeControlStatusContext {
                if let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
                    let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                    let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                    delegate?.didTimeControlStatusChange(oldStatus: oldStatus, newStatus: newStatus)
                    return
                }
            }
        case ReeMuxPlayerObserver.kStatus:
            if context == &statusContext {
                if let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let newStatus = AVPlayerItem.Status(rawValue: newValue) {
                    delegate?.didStatusChange(status: newStatus)
                    return
                }
            }
        default:
            break
        }

        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}
