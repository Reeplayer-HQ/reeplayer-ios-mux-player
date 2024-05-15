//
//  ReeMuxPlayerView.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

import Combine
import SwiftUI

public struct ReeMuxPlayerView: View {
    // MARK: Variables

    private let playbackId: String?
    private let playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?
    private let statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?
    private let timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?
    private let options: ReeMuxPlayerOptions?

    // MARK: Life Cycle

    public init(
        playbackId: String?,
        playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>? = nil,
        statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>? = nil,
        timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>? = nil,
        options: ReeMuxPlayerOptions? = nil
    ) {
        self.playbackId = playbackId
        self.playerActionPublisher = playerActionPublisher
        self.statusObserver = statusObserver
        self.timerObserver = timerObserver
        self.options = options
    }

    // MARK: Body Component

    public var body: some View {
        ReeMuxPlayerRepresentable(
            playbackId: playbackId,
            playerActionPublisher: playerActionPublisher,
            statusObserver: statusObserver,
            timerObserver: timerObserver,
            options: options
        )
    }
}
