//
//  ContentView.swift
//  amazingtalker-watchOS WatchKit Extension
//
//  Created by Arthur Kao on 2021/5/9.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject
    var state: ScheduleState

    private func gridItems(for geometry: GeometryProxy) -> [GridItem] {
        [GridItem(.fixed(geometry.size.width / 2)), GridItem(.fixed(geometry.size.width / 2))]
    }

    var body: some View {
        VStack {
            if state.weekdayItemsAnimationFlag {
                Text(state.rangeText)
                    .transition(.scale(scale: 0, anchor: .bottom))
            } else {
                Text(" ")
            }
            HStack {
                Button(action: {
                    state.previousWeek()
                }) {
                    Image(systemName: "chevron.backward")
                }
                Button(action: {
                    state.nextWeek()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
        }
        .animation(Animation.easeInOut(duration: 0.15), value: state.weekdayItemsAnimationFlag)
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack {
                    if state.weekdayItemsAnimationFlag {
                        TabView {
                            ForEach(state.weekdayItems.filter { !$0.times.isEmpty }) { weekDayItems in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(weekDayItems.weekdaySymbol)
                                        Spacer()
                                    }
                                    if state.isLoading {
                                        ProgressView()
                                    } else {
                                        ScrollView(.vertical) {
                                            LazyVGrid(columns: gridItems(for: geometry), alignment: .leading, spacing: 4) {
                                                ForEach(weekDayItems.times) { time in
                                                    Text(time.text)
                                                        .foregroundColor(time.isBooked ? Color("AccentColor") : .white)
                                                }
                                            }
                                        }
                                    }
                                    Spacer(minLength: geometry.safeAreaInsets.bottom)
                                }
                                .padding()
                            }
                        }
                        .frame(width: geometry.size.width)
                        .tabViewStyle(PageTabViewStyle())
                        .transition(.move(edge: .top))
                    }
                }
            }
            .ignoresSafeArea()
        }
        .animation(Animation.easeInOut(duration: 0.15), value: state.weekdayItemsAnimationFlag)
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previewDate: Date {
        DateComponents(calendar: .current, year: 2020, month: 11, day: 23).date!
    }

    static var previews: some View {
        Group {
            ContentView(
                state: ScheduleState(
                    referenceDate: previewDate,
                    hidePassItems: false,
                    provider: PreviewScheduleProvider()
                )
            )
        }
    }
}
