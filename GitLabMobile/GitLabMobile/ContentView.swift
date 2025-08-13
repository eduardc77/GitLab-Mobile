//
//  ContentView.swift
//  GitLabMobile
//
//  Created by User on 8/12/25.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            ExploreRootView()
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { Text("Notifications") }
                .tabItem { Label("Notifications", systemImage: "bell") }

            NavigationStack { Text("Account") }
                .tabItem { Label("Account", systemImage: "person.circle") }
        }
    }
}
