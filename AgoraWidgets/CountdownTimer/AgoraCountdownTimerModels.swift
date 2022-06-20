//
//  AgoraCountdownModel.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/5.
//


// View Data
enum AgoraCountdownState: Int, Convertable {
    case end = 0, duration = 1
}

// Origin Data
struct AgoraCountdownRoomData: Convertable {
    var startTime: Int64            // millisecond
    var state: AgoraCountdownState
    var duration: Int64             // second
}
