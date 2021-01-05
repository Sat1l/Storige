//
//  ViewPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//

import SwiftUI
import CoreData


struct ViewPage: View//
{
    @State var showNewItemSheet1 = false
    @State var showNewItemSheet2 = false
    @State var selected = 0
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Item.serialNum, ascending: true)
    ])
    var items: FetchedResults<Item>
    
    var body: some View
    {
        NavigationView{
            List{
                ForEach(items) { Item in
                    NavigationLink(destination: NewItemSheet(TypeOfView: 2, uuid: Item.itemid, serialNum: Item.serialNum!, amountInt: Item.amount))
                    {
                    VStack(alignment: .leading){
                        Text("\(Item.serialNum ?? "")")
                            .font(.headline)
                        Text("Кол-во: \(Item.amount)")
                            .font(.subheadline)
                        Text("UUID: \(Item.itemid!)")
                            .font(.subheadline)
                    }.frame(height: 50)
                    }}
                .onDelete { indexSet in
                    for index in indexSet {
                        viewContext.delete(items[index])
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Обзор", displayMode: .automatic)
            .navigationBarItems(trailing: Button(action: {
                showNewItemSheet1 = true
            }, label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }))
            .sheet(isPresented: $showNewItemSheet1, content: {NewItemSheet(TypeOfView: 1)})
        }
    }

}
