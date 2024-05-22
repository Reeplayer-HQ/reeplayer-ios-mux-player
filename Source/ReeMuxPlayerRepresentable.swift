//
//  ReeMuxPlayerRepresentable.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

import AVKit
import Combine
import MuxPlayerSwift
import SwiftUI

public struct ReeMuxPlayerRepresentable: UIViewControllerRepresentable {
    // MARK: Variables

    private let item: ReeMuxPlayerItem?
    private let playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?
    private let statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?
    private let timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?

    @State var playerViewController: AVPlayerViewController = .init()

    // MARK: Life Cycle

    public init(
        item: ReeMuxPlayerItem?,
        playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?,
        statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?,
        timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?
    ) {
        self.item = item
        self.playerActionPublisher = playerActionPublisher
        self.statusObserver = statusObserver
        self.timerObserver = timerObserver
    }

    // MARK: Methods

    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        // Set attributes
        playerViewController.modalPresentationStyle = .automatic
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        playerViewController.entersFullScreenWhenPlaybackBegins = false
        playerViewController.exitsFullScreenWhenPlaybackEnds = false
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.showsPlaybackControls = true
        playerViewController.restoresFocusAfterTransition = true
        playerViewController.updatesNowPlayingInfoCenter = true

        // Add time observer
        playerViewController.delegate = context.coordinator

        return playerViewController
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Check if the item has changed
        context.coordinator.checkItemChange(item: item)
    }

    public func makeCoordinator() -> ReeMuxPlayerCoordinator {
        return ReeMuxPlayerCoordinator(
            playerViewController: playerViewController,
            playerActionPublisher: playerActionPublisher,
            statusObserver: statusObserver,
            timerObserver: timerObserver
        )
    }

    public static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ReeMuxPlayerCoordinator) {
        print("ReeMuxPlayerRepresentable: dismantleUIViewController")
        coordinator.removeAllObservers()
    }
}
