//
//  ContentView.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/6.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject
    var state: ScheduleState

    let appearTransition = AnyTransition.opacity

    let backTransition = AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .identity)

    let nextTransition = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .identity)

    func pageTransition(for diff: Int) -> AnyTransition {
        if state.pageVector == 0 {
            return appearTransition
        } else if state.pageVector > 0 {
            return nextTransition
        } else {
            return backTransition
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("available_times_label_text")
                    .padding(.bottom, 4)
                    .font(.title)
                HStack {
                    HStack(spacing: 0) {
                        Button(action: {
                            state.previousWeek()
                        }) {
                            Image(systemName: "chevron.backward")
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color.gray)
                        .border(Color.gray)
                        .disabled(!state.canGoBack)
                        .opacity(state.canGoBack ? 1 : 0.3)
                        Button(action: {
                            state.nextWeek()
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color.gray)
                        .border(Color.gray)
                    }
                    .padding(.vertical, 4)
                    Text(state.rangeText)
                        .lineLimit(1)
                }
                HStack {
                    Spacer()
                    Text("timezone_label_text \(state.timeZoneName)")
                        .font(.system(size: 12))
                }
                if state.weekdayItemsAnimationFlag {
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(state.weekdayItems) { weekdayItem in
                            VStack(alignment: .center) {
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(weekdayItem.times.isEmpty ? Color("DisableColor"): .accentColor)
                                Group {
                                    Text(weekdayItem.weekdaySymbol)
                                    Text(weekdayItem.day)
                                }
                                .lineLimit(1)
                                ForEach(weekdayItem.times) { time in
                                    if !state.isLoading {
                                        Text(time.text).lineLimit(1)
                                            .font(.system(size: 13))
                                            .foregroundColor(time.isBooked ? Color("DisableColor"): .accentColor)
                                            .padding(.vertical, 1)
                                    }
                                }
                            }
                            .opacity(weekdayItem.isEnable ? 1 : 182/255)
                        }
                    }
                    .transition(pageTransition(for: state.pageVector))
                }
            }
            .animation(Animation.easeInOut(duration: 0.15), value: state.weekdayItemsAnimationFlag)
            .padding()
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < 0 {
                        state.nextWeek()
                    }
                    if value.translation.width > 0 {
                        state.previousWeek()
                    }
                }
        )
        .overlay(
            Group {
                if state.isLoading {
                    ProgressView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.15))
        )
        .progressViewStyle(CircularProgressViewStyle())
        .background(Color(UIColor.white).ignoresSafeArea())
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
            .previewDevice(PreviewDevice(rawValue: "iPhone SE2"))
            ContentView(
                state: ScheduleState(
                    referenceDate: previewDate,
                    hidePassItems: false,
                    provider: PreviewScheduleProvider()
                )
            )
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
        }
    }
}
