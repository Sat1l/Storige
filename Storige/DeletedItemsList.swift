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
                            Text("id: \(Item.itemid!)")
                                .font(.subheadline)
                            Text("Удалено?: \(String(Item.isOnDeleted))")
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
    }
    func updateArray(){
        fetchedItemsForDeleting = deletedItems.filter{$0.isOnDeleted == true}.sorted(by: {$0.creationDate! < $1.creationDate!})
    }
}
