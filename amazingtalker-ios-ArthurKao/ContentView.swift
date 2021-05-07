//
//  ContentView.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/6.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("授課時間")
                    .padding(.bottom, 4)
                    .font(.title)
                HStack {
                    HStack(spacing: 0) {
                        Group {
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                                Image(systemName: "chevron.backward")
                            }
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color.gray)
                        .border(Color.gray)
                    }
                    .padding(.vertical, 4)
                    Text("2021/06/06 - 13")
                    Spacer()
                    Text("GMT+08:00")
                        .font(.system(size: 12))
                }
                HStack(spacing: 4) {
                    ForEach(Range(1...7)) { weekDay in
                        VStack(alignment: .center) {
                            Rectangle()
                                .frame(height: 2)
                            HStack {
                                Spacer()
                                Text("\(weekDay)")
                                Spacer()
                            }
                            ForEach(Range(1...1)) { _ in
                                Text("00:00").lineLimit(1)
                                    .font(.system(size: 13))
                            }
                        }
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
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE2"))
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                .colorScheme(.dark)
        }
    }
}
