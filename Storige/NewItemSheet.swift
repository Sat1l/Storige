//
//  NewItemSheet.swift
//  Storige
//
//  Created by Максим Сателайт on 08.12.2020.
//

import SwiftUI
import Combine

struct NewItemSheet: View
{
    @State var serialNum = ""
    @State var amount = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    var body: some View
    {
        NavigationView
        {
            
            Form
            {
                TextField("Название", text: $serialNum)
                    .keyboardType(.default)
                TextField("Количество", text: $amount)
                    .keyboardType(.numberPad)
                    .onReceive(Just(amount))
                    {
                        newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.amount = filtered}
                    }
                .navigationBarItems(trailing: Button(action: {
                let newItem = Item(context: viewContext)
                newItem.serialNum = self.serialNum
                newItem.amount = self.amount
                do{
                    try viewContext.save()
                    print("item saved")
                    presentationMode.wrappedValue.dismiss()
                    }
                catch{
                    print(error.localizedDescription)
                }
            }, label: {
                Text("Добавить")
            }))
        }.navigationTitle("Новый объект")
    }
}
}


struct NewItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewItemSheet()
    }
}
