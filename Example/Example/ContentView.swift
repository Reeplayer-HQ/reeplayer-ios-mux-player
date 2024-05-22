//
//  ContentView.swift
//  Example
//
//  Created by Onur Var on 15.05.2024.
//

import Combine
import ReeMuxPlayer
import SwiftUI

struct ContentView: View {
    private let playerActionPublisher: PassthroughSubject<ReeMuxPlayerPlayerActionPublisherType, Never> = .init()
    private let statusObserver: PassthroughSubject<ReeMuxPlayerStatusObserverType, Never> = .init()
    private let timerObserver: PassthroughSubject<ReeMuxPlayerTimerObserverType, Never> = .init()
    @State var item: ReeMuxPlayerItem? = nil
    @State var cancellables: Set<AnyCancellable> = []

    var body: some View {
        VStack {
            ReeMuxPlayerView(
                item: item,
                playerActionPublisher: playerActionPublisher,
                statusObserver: statusObserver,
                timerObserver: timerObserver
            )
            .aspectRatio(16 / 9, contentMode: .fit)
            Spacer()
            Button("GO TO 00:50") {
                playerActionPublisher.send(.GoTo(milliSeconds: 50000))
            }
            .padding()
            Button("Pause") {
                playerActionPublisher.send(.Pause)
            }
            .padding()
            Button("Play") {
                playerActionPublisher.send(.Play)
            }
            .padding()

            Button("Sample Video") {
                item = .init(playbackId: "qxb01i6T202018GFS02vp9RIe01icTcDCjVzQpmaB00CUisJ4")
            }
            .padding()

            Button("Sample Video with loop") {
                item = .init(
                    playbackId: "qxb01i6T202018GFS02vp9RIe01icTcDCjVzQpmaB00CUisJ4",
                    loopRangeInMilliseconds: 15000 ... 25000
                )
            }
            .padding()
        }
        .onAppear(perform: {
            statusObserver.sink(receiveValue: { status in
                print("statusObserver", status)
            })
            .store(in: &cancellables)
            timerObserver.sink { timer in
                print("timerObserver", timer)
            }
            .store(in: &cancellables)
        })
    }
}

#Preview {
    ContentView()
}
