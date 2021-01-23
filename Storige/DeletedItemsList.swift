//
//  DeletedItemsList.swift
//  Storige
//
//  Created by Максим Сателайт on 23.01.2021.
//

import SwiftUI

struct DeletedItemsList: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
            List(){
                ForEach(hernya.deletedItemsList) {  Item in
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
                            Text("Кол-во: \(Item.itemid!)")
                                .font(.subheadline)
                        }.frame(height: 50)
                        })}
            }
            .navigationBarTitle("text", displayMode: .inline)
    }
}
