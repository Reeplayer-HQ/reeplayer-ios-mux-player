//
//  ReeMuxPlayerRepresentable.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

import AVKit
import Combine
import SwiftUI

public struct ReeMuxPlayerRepresentable: UIViewControllerRepresentable {
    // MARK: Variables

    let url: URL?
    private let playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?
    private let statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?
    private let timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?
    private let options: ReeMuxPlayerOptions?

    @State var playerViewController: AVPlayerViewController = .init()

    // MARK: Life Cycle

    public init(
        url: URL?,
        playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?,
        statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?,
        timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?,
        options: ReeMuxPlayerOptions?
    ) {
        self.url = url
        self.playerActionPublisher = playerActionPublisher
        self.statusObserver = statusObserver
        self.timerObserver = timerObserver
        self.options = options
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

        // Set the player
        playerViewController.player = context.coordinator.player

        // Add time observer
        playerViewController.delegate = context.coordinator

        return playerViewController
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Check if the url has changed
        context.coordinator.checkUrlChange(url: url)

        // There may be updates to the options, so we need to update the coordinator
        context.coordinator.options = options
    }

    public func makeCoordinator() -> ReeMuxPlayerCoordinator {
        return ReeMuxPlayerCoordinator(
            playerViewController: playerViewController,
            playerActionPublisher: playerActionPublisher,
            statusObserver: statusObserver,
            timerObserver: timerObserver,
            options: options
        )
    }

    public static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ReeMuxPlayerCoordinator) {
        print("ReeMuxPlayerRepresentable: dismantleUIViewController")
        coordinator.removeAllObservers()
    }
}
