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
    @State var showNewItemSheet = false
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
                    NavigationLink(destination: QrCodeGen(uuid: Item.itemid!, itemSerial: Item.serialNum!, itemAmount: Item.amount) .navigationBarTitle("Детали"))
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
