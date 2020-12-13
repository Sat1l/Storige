//
//  FoundItem.swift
//  Storige
//
//  Created by Максим Сателайт on 13.12.2020.
//

import SwiftUI

struct FoundItem: View {
    var itemSerial: String
    var itemAmount: Int16
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Информация")){
                    Text("Наименование: \(itemSerial)")
                    Text("Кол-во: \(itemAmount)")
                }
            }
                .navigationBarTitle(itemSerial)
        }
    }
        
}
