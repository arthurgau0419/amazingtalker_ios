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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("授課時間")
                    .padding(.bottom, 4)
                    .font(.title)
                HStack {
                    HStack(spacing: 0) {
                        Group {
                            Button(action: {
                                state.nextWeek()
                            }) {
                                Image(systemName: "chevron.backward")
                            }
                            Button(action: {
                                state.previousWeek()
                            }) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color.gray)
                        .border(Color.gray)
                    }
                    .padding(.vertical, 4)
                    HStack {
                        Text(state.rangeText)
                        Spacer(minLength: 0)
                        Text("時間以 \(state.timeZoneName) 顯示")
                            .font(.system(size: 12))
                    }
                    .lineLimit(1)
                }
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
                            ForEach(Range(1...1)) { _ in
                                Text("00:00").lineLimit(1)
                                    .font(.system(size: 13))
                            }
                        }
                        .opacity(weekdayItem.isEnable ? 1 : 182/255)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(state: ScheduleState())
                .previewDevice(PreviewDevice(rawValue: "iPhone SE2"))
            ContentView(state: ScheduleState())
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                .colorScheme(.dark)
        }
    }
}
