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
        NavigationView(){
        List(){
                ForEach(fetchedItemsForDeleting) {  Item in
                        VStack(alignment: .leading){
                            Text("\(Item.serialNum ?? "")")
                                .font(.headline)
                            Text("Кол-во: \(Item.amount)")
                                .font(.subheadline)
                        }
                        }
                    .onDelete { indexSet in //отклик и обработка удаления предмета в списке начало
                        for index in indexSet {
                            viewContext.delete(fetchedItemsForDeleting[index])
                            }
                        do {
                            try viewContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
            }
        }
        .navigationBarTitle("Удаленные предметы", displayMode: .automatic)
            .navigationBarItems(trailing:
                Button(action: {
                    self.showingAlert = true
                }, label: {
                    Text("dumpAll")
                }))

    }
}
