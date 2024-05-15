//
//  ReeMuxPlayerCoordinator.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

import AVKit
import Combine
import MuxPlayerSwift

public class ReeMuxPlayerCoordinator: NSObject {
    // MARK: Variables

    private let playerViewController: AVPlayerViewController
    private let playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?
    private let statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?
    private let timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?
    private var playbackId: String? = nil
    private let observer = ReeMuxPlayerObserver()
    private var cancellables = Set<AnyCancellable>()
    private var player: AVPlayer? { playerViewController.player }

//    let player = AVPlayer()
    var options: ReeMuxPlayerOptions?

    // MARK: Life Cycle

    public init(
        playerViewController: AVPlayerViewController,
        playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?,
        statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?,
        timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?,
        options: ReeMuxPlayerOptions?
    ) {
        // Set the playerViewController
        self.playerViewController = playerViewController
        self.playerActionPublisher = playerActionPublisher
        self.statusObserver = statusObserver
        self.timerObserver = timerObserver
        self.options = options

        // Call the super init
        super.init()

        // Set the delegate of the playerViewController and player
        observer.delegate = self

        // Initialize AVplayer and set it playerViewController
        let player = AVPlayer()
        observer.addTimeControlStatusObserver(toPlayer: player)
        observer.addTimeObserver(toPlayer: player)
        playerViewController.player = player

        // Sink the overlayActionPublisher
        playerActionPublisher?.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .Play:
                self.playVideo()
            case .Pause:
                self.pauseVideo()
            case .GoTo(let milliSeconds):
                self.goTo(milliSeconds: milliSeconds)
            }
        }
        .store(in: &cancellables)
    }

    deinit {
        print("ReeMuxPlayerCoordinator: deinit")
        disableAudioSession()
    }

    func removeAllObservers() {
        if let player {
            if let playerItem = player.currentItem {
                observer.removeStatusObserver(toPlayerItem: playerItem)
                observer.removePlayerReachEndObserver(toPlayerItem: playerItem)
            }
            observer.removeTimeObserver(fromPlayer: player)
            observer.removeTimeControlStatusObserver(fromPlayer: player)
        }
        observer.delegate = nil
    }

    // MARK: URL Methods

    /// Checks if the playbackId has changed. If so, it refreshes the video player with the new playbackId.
    public func checkPlaybackIdChange(playbackId: String?) {
        // Check if the playbackId is not nil
        guard let playbackId = playbackId else {
            cleanVideoPlayer()
            return
        }

        // Check if the playbackId has changed
        guard playbackId != self.playbackId else { return }

        // Set the new playbackId
        self.playbackId = playbackId

        // Open the video player with the new playbackId
        openPlaybackId(playbackId: playbackId)
    }

    /// Opens the video player with the given URL
    private func openPlaybackId(playbackId: String) {
        // Remove observers from the current playerItem if exists
        if let playerItem = playerViewController.player?.currentItem {
            observer.removeStatusObserver(toPlayerItem: playerItem)
            observer.removePlayerReachEndObserver(toPlayerItem: playerItem)
        }

        // Prepare the AVPlayerViewControler with new playbackId
        playerViewController.prepare(playbackID: playbackId)

        // Enable audio session
        enableAudioSession()

        // Notify the statusObserver that the video player is not ready and is loading
        statusObserver?.send(.PlayerStatusChanged(type: .Loading))
        statusObserver?.send(.VideoStatusChanged(type: .NotReady))

        // Set the player's volume and mute status
        player?.isMuted = options?.isMuted ?? false

        // Set AVPlayer settings
        player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible

        // Add observers to the new playerItem
        if let playerItem = playerViewController.player?.currentItem {
            observer.addStatusObserver(toPlayerItem: playerItem)
            observer.addPlayerReachEndObserver(toPlayerItem: playerItem)
        }
    }

    /// Cleans the video player and removes all observers
    private func cleanVideoPlayer() {
        // Remove observers from the current playerItem if exists
        if let playerItem = playerViewController.player?.currentItem {
            observer.removeStatusObserver(toPlayerItem: playerItem)
            observer.removePlayerReachEndObserver(toPlayerItem: playerItem)
        }

        // Clean the player
        player?.replaceCurrentItem(with: nil)
    }

    // MARK: Action Methods

    /// Plays the video
    private func playVideo() {
        // Check if the player exist
        guard let player = playerViewController.player else { return }

        // Check if the video reached the end. If so, seek to the beginning
        if player.currentItem?.duration == player.currentTime() {
            player.seek(to: .zero)
        }

        // Play the video
        player.play()
    }

    /// Pauses the video
    private func pauseVideo() {
        // Check if the player exist
        guard let player = playerViewController.player else { return }

        // Pause the video
        player.pause()
    }

    /// Goes to the given milliSeconds
    private func goTo(milliSeconds: Double) {
        // Check if the player exist
        guard let player = playerViewController.player else { return }

        let time: CMTime = .init(seconds: milliSeconds / 1000, preferredTimescale: 1000)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    // MARK: AVAudioSession Methods

    func enableAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }

    func disableAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print(error)
        }
    }
}

extension ReeMuxPlayerCoordinator: AVPlayerViewControllerDelegate {}

extension ReeMuxPlayerCoordinator: ReeMuxPlayerObserverDelegate {
    func didCurrentTimeChange(currentTimeInMilliSeconds: Double) {
        timerObserver?.send(.CurrentTimeChanged(milliSeconds: currentTimeInMilliSeconds))

        // Check if loopRangeInMilliseconds is set and the currentTimeInMilliSeconds is greater than the upperBound, then go to the lowerBound
        if let loopRangeInMilliseconds = options?.loopRangeInMilliseconds, currentTimeInMilliSeconds > loopRangeInMilliseconds.upperBound {
            let lowerBoundInMilliSeconds = loopRangeInMilliseconds.lowerBound
            goTo(milliSeconds: lowerBoundInMilliSeconds)
        }
    }

    func didTimeControlStatusChange(oldStatus: AVPlayer.TimeControlStatus?, newStatus: AVPlayer.TimeControlStatus?) {
        guard let newStatus, let oldStatus, newStatus != oldStatus else { return }
        let type: ReeMuxPlayerPlayerStatusType = switch newStatus {
        case .paused:
            .Paused
        case .waitingToPlayAtSpecifiedRate:
            .Loading
        case .playing:
            .Playing
        @unknown default:
            fatalError()
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.statusObserver?.send(.PlayerStatusChanged(type: type))
        }
    }

    func didStatusChange(status: AVPlayerItem.Status) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            switch status {
            case .readyToPlay:

                // Check if the player exist
                guard let player = playerViewController.player else { return }

                // Notify the statusObserver that the video player is ready
                self.statusObserver?.send(.VideoStatusChanged(type: .Ready))

                // Notify the timerObserver that the total time has changed
                let totalTimeInMilliSeconds: Double = CMTimeGetSeconds(player.currentItem?.duration ?? .zero) * 1000
                self.timerObserver?.send(.TotalTimeChanged(milliSeconds: totalTimeInMilliSeconds))

                // Check if the video should play automatically
                if let autoPlayVideoWhenReady = self.options?.autoPlayVideoWhenReady, autoPlayVideoWhenReady {
                    self.playVideo()
                }

            case .failed:

                // Notify the statusObserver that the video player has failed
                self.statusObserver?.send(.VideoStatusChanged(type: .Failed))
            default:

                // Notify the statusObserver that the video player is unknown
                self.statusObserver?.send(.VideoStatusChanged(type: .Unknown))
            }
        }
    }

    func didPlayerReachEnd() {
        // Check if the player exist
        guard let player = playerViewController.player else { return }

        guard let loopVideoWhenEndReached = options?.loopVideoWhenEndReached, loopVideoWhenEndReached else { return }
        player.seek(to: .zero)
        player.play()
    }
}
