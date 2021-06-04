//
//  ViewPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//

import SwiftUI

struct ContentView: View {
    @State var selected = 0
    var body: some View {
    TabView(selection: $selected){
            ViewPage().tabItem {
                Image(systemName: "shippingbox.fill")
                Text("Обзор")
            }.tag(0)
        DeletedItemsList().tabItem {
                Image(systemName: "trash.fill")
                Text("Удаленные предметы")
            }.tag(2)
        }
    }
}
