//
//  ReeMuxPlayerStatusObserverType.swift
//  ReeMuxPlayer
//
//  Created by Onur Var on 15.05.2024.
//

public enum ReeMuxPlayerStatusObserverType {
    case PlayerStatusChanged(type: ReeMuxPlayerPlayerStatusType)
    case VideoStatusChanged(type: ReeMuxPlayerVideoStatusType)
}
