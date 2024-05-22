//
//  ReeMuxPlayerItem.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

import Foundation

public struct ReeMuxPlayerItem: Identifiable, Equatable {
    public let id: String
    public let playbackId: String
    public let loopRangeInMilliseconds: ClosedRange<Double>?
    public let autoPlayVideoWhenReady: Bool
    public let isMuted: Bool
    public let loopVideoWhenEndReached: Bool

    public init(
        playbackId: String,
        loopRangeInMilliseconds: ClosedRange<Double>? = nil,
        autoPlayVideoWhenReady: Bool = true,
        isMuted: Bool = false,
        loopVideoWhenEndReached: Bool = false
    ) {
        self.id = UUID().uuidString
        self.playbackId = playbackId
        self.loopRangeInMilliseconds = loopRangeInMilliseconds
        self.autoPlayVideoWhenReady = autoPlayVideoWhenReady
        self.isMuted = isMuted
        self.loopVideoWhenEndReached = loopVideoWhenEndReached
    }
}
