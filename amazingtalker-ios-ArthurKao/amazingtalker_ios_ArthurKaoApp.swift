//
//  amazingtalker_ios_ArthurKaoApp.swift
//  amazingtalker-ios-ArthurKao
//
//  Created by Arthur Kao on 2021/5/6.
//

import SwiftUI

@main
struct amazingtalker_ios_ArthurKaoApp: App {

    @StateObject
    var state = ScheduleState(
        referenceDate: DateComponents(calendar: .current, year: 2020, month: 11, day: 23).date!,
        hidePassItems: false,
        provider: NetworkScheduleProvider()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
                .colorScheme(.light)
        }
    }
}
