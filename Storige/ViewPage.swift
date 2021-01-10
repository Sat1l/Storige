//
//  ViewPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//

import SwiftUI
import CoreData

enum ActiveSheet: Identifiable {
    case first, second
    var id: Int {hashValue}
}

struct ViewPage: View//
{
    @State var activeSheet: ActiveSheet?
    @State var sortSheet = false
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
                    Button(action: {
                        activeSheet = .second
                        hernya.sharedUuid = Item.itemid
                        hernya.sharedSerialNum = Item.serialNum ?? ""
                        hernya.sharedAmount = Item.amount
                    }, label:
                    {
                    VStack(alignment: .leading){
                        Text("\(Item.serialNum ?? "")")
                            .font(.headline)
                        Text("Кол-во: \(Item.amount)")
                            .font(.subheadline)
                        Text("UUID: \(Item.itemid!)")
                            .font(.subheadline)
                    }.frame(height: 50)
                    })}
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
            .navigationBarItems(leading: Button(action:{
                sortSheet.toggle()
            }, label: {
                Text("Сортировка")
            }), trailing: Button(action: {activeSheet = .first}, label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }))
            .sheet(item: $activeSheet) { item in
                switch item {
                case .first:
                    NewItemSheet(TypeOfView: 1)
                case .second:
                    NewItemSheet(TypeOfView: 2, uuid: hernya.sharedUuid, serialNum: hernya.sharedSerialNum, amountInt: hernya.sharedAmount)}
            }
            .actionSheet(isPresented: $sortSheet) {
                ActionSheet(title: Text("Change background"), buttons: [
                    .default(Text("По алфавиту")) {},
                    .default(Text("Green")) {},
                    .default(Text("Blue")) {},
                    .cancel()
                ])
            }
        }
    }
}

struct hernya{
    static var sharedUuid: UUID?
    static var sharedSerialNum = ""
    static var sharedAmount: Int64 = 1
}
