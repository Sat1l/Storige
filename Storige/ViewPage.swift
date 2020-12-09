//
//  ViewPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//

import SwiftUI // импорт свифтуи
import CoreData // импорт кордаты


struct ViewPage: View//
{
    @State var showNewItemSheet = false
    var body: some View//
    {
        NavigationView{//
        Text("oioioioio")//
            .navigationBarTitle("Обзор", displayMode: .automatic)
            .navigationBarItems(trailing: Button(action: {
                showNewItemSheet = true
            }, label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }))
            .sheet(isPresented: $showNewItemSheet, content: {NewItemSheet()})
        }
    }
}

struct ViewPage_Previews: PreviewProvider {
    static var previews: some View {
        ViewPage().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
