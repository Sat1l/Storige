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
    public var items: FetchedResults<Item>
    @State var SortedItems:[Item] = []
    @State var typeOfSorting: Int8 = 1
    var body: some View
    {
        NavigationView{
            List{
                ForEach(items.filter{$0.isOnDeleted == false}) {  Item in
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
                        Text("Айдишник: \(Item.itemid!)")
                            .font(.subheadline)
                        Text("Удалено?: \(String(Item.isOnDeleted))")
                            .font(.subheadline)
                    }.frame(height: 70)
                    })}
                .onDelete { indexSet in
                    for index in indexSet {
                        viewContext.delete(SortedItems[index])
                    }
                    do {
                        try viewContext.save()
                        switch typeOfSorting{
                        case 1:
                            forSorting(Type: 1)
                        case 2:
                            forSorting(Type: 2)
                        case 3:
                            forSorting(Type: 3)
                        default:
                            print("")
                        }
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
                        .onDisappear(perform: {
                            hernya.deletedItemsList = items.filter{$0.isOnDeleted == true}
                        })
                case .second:
                    NewItemSheet(TypeOfView: 2, uuid: hernya.sharedUuid, serialNum: hernya.sharedSerialNum, amountInt: hernya.sharedAmount)
                }
            }
            .actionSheet(isPresented: $sortSheet) {
                ActionSheet(title: Text("Сортировать по"), buttons: [
                    .default(Text("Кол-во возрастание")) {forSorting(Type: 1)},
                    .default(Text("Кол-во убывание")) {forSorting(Type: 2)},
                    .default(Text("По Алфавиту")) {forSorting(Type: 3)},
                    .cancel()
                ])
            }
        }.onAppear{
            hernya.deletedItemsList = items.filter{$0.isOnDeleted == true}
            switch typeOfSorting{
            case 1:
                forSorting(Type: 1)
            case 2:
                forSorting(Type: 2)
            case 3:
                forSorting(Type: 3)
            default:
                print("gg")
            }
        }
    }
    func forSorting(Type: Int){
        switch Type{
        case 1: // возрастание количества
            typeOfSorting = 1
            SortedItems = items.sorted(by: {$0.amount < $1.amount})
        case 2: // убывание количества
            typeOfSorting = 2
            SortedItems = items.sorted(by: {$0.amount > $1.amount})
        case 3: //убывание по алфавиту
            typeOfSorting = 3
            SortedItems = items.sorted(by: {$0.serialNum! < $1.serialNum!})
        default:
            print("yopta")
        }
    }
}

struct hernya{
    static var sharedUuid: UUID?
    static var sharedSerialNum = ""
    static var sharedAmount: Int64 = 1
    static var deletedItemsList:[Item] = []
}
