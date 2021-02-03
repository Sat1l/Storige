//
//  DeletedItemsList.swift
//  Storige
//
//  Created by Максим Сателайт on 23.01.2021.
//

import SwiftUI

struct DeletedItemsList: View {
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.serialNum, ascending: true)])
    var deletedItems: FetchedResults<Item>
    @State var fetchedItemsForDeleting:[Item] = []
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAlert = false
    var body: some View {
            
        List(){
                ForEach(fetchedItemsForDeleting) {  Item in
                        Button(action: {
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
                        }
                        })}
                    .onDelete { indexSet in //отклик и обработка удаления предмета в списке начало
                        for index in indexSet {
                            viewContext.delete(fetchedItemsForDeleting[index])
                            }
                        do {
                            try viewContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        updateArray()
                    }
            }
            .onAppear{
                updateArray()
            }
            .navigationBarTitle("text", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.showingAlert = true
                }, label: {
                    Text("dumpAll")
                }))
            .actionSheet(isPresented: $showingAlert) {
                ActionSheet(title: Text("эти объекты будут удалены без возможности восстанловления"),  buttons: [
                    .default(Text("Удалить")) {
                        for item in deletedItems{
                        if item.isOnDeleted == true{
                            viewContext.delete(item)
                        }
                        }
                        do {
                            try viewContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        updateArray()
                    },
                    .cancel()
                ])
            }
    }
    func updateArray(){
        fetchedItemsForDeleting = deletedItems.filter{$0.isOnDeleted == true}.sorted(by: {$0.creationDate! < $1.creationDate!})
    }
}
