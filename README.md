# amaizngtalker-ios-ArthurKap

### 開發環境
- Xcode 12.5
### 相容性
- iOS 14.1~
- MacOS 11.3~
- WatchOS 7.4~
### Dependent Framework
 - Foundation
 - SwiftUI
 - Combine
 - WatchKit
 
### Project Architecture
```
project
│   README.md
│
└───amazingtalker-ios-ArthurKao(iOS, MacOS Application)
│   │   App
│   │   ScheduleState
│   │   ContentView
│   │
│   └───ScheduleProvider
│       │    NetworkProvider
│       └─── SPreviewProvider
│   
└───amazingtalker-watchOS WatchKit Extension(WatchOS Application)
│   │
│   └─── ContentView
│
└───amazingtalker-ios-network
│   │
│   │   NetworkManager
│   │
│   └── DecodableModel
│       │   Schedule
│       └── ScheduleItem
│
└───amazingtalker-ios-ArthurKaoTests
│   │   
│   └── ScheduleStateTests
│
└───amazingtalker-ios-networkTests
    │   DecodableTests
    └── NetworkManagerTests
```



