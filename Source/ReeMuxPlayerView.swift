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

    private let item: ReeMuxPlayerItem?
    private let playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>?
    private let statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>?
    private let timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>?

    // MARK: Life Cycle

    public init(
        item: ReeMuxPlayerItem?,
        playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never>? = nil,
        statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never>? = nil,
        timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never>? = nil
    ) {
        self.item = item
        self.playerActionPublisher = playerActionPublisher
        self.statusObserver = statusObserver
        self.timerObserver = timerObserver
    }

    // MARK: Body Component

    public var body: some View {
        ReeMuxPlayerRepresentable(
            item: item,
            playerActionPublisher: playerActionPublisher,
            statusObserver: statusObserver,
            timerObserver: timerObserver
        )
    }
}
