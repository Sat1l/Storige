//
//  ViewPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @State var selected = 0
    var body: some View {
        TabView(selection: $selected){
            ViewPage().tabItem {
                Image(systemName: "shippingbox.fill")
                Text("Обзор")
            }.tag(0)
            SettingsPage().tabItem {
                Image(systemName: "gear")
                Text("Настройки")
            }.tag(1)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
