//
//  ReeMuxPlayerOptions.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

public struct ReeMuxPlayerOptions {
    let autoPlayVideoWhenReady: Bool
    let isMuted: Bool
    let loopVideoWhenEndReached: Bool
    let loopRangeInMilliseconds: ClosedRange<Double>?

    public init(
        autoPlayVideoWhenReady: Bool = true,
        isMuted: Bool = false,
        loopVideoWhenEndReached: Bool = true,
        loopRangeInMilliseconds: ClosedRange<Double>? = nil
    ) {
        self.autoPlayVideoWhenReady = autoPlayVideoWhenReady
        self.isMuted = isMuted
        self.loopVideoWhenEndReached = loopVideoWhenEndReached
        self.loopRangeInMilliseconds = loopRangeInMilliseconds
    }
}
