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
        provider: NetworkScheduleProvider(teacher: "amy-estrada")
    )

    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
                .colorScheme(.light)
        }
    }
}
