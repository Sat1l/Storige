//
//  NewItemSheet.swift
//  Storige
//
//  Created by Максим Сателайт on 08.12.2020.
//

import SwiftUI
import Combine
import CoreImage.CIFilterBuiltins

struct NewItemSheet: View{
    @State var serialNum = ""
    @State var journalNum = ""
    @State var amount = ""
    @State var amountInt: Int64 = 1
    @State var items: [Any] = []
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    var body: some View
    {NavigationView{
            Form
            {
                TextField("Название", text: $serialNum)
                    .keyboardType(.default)
                    .onReceive(Just(serialNum)) { inputValue in
                                if inputValue.count > 100 {
                                    self.serialNum.removeLast()
                                }
                    }

                TextField("Журнальный номер", text: $journalNum)
                    .keyboardType(.default)
                    .onReceive(Just(journalNum)) { inputValue in
                                if inputValue.count > 30 {
                                    self.journalNum.removeLast()
                                }
                    }
                TextField("Количество", text: $amount)
                    .keyboardType(.numberPad)
                    .onReceive(Just(amount))
                    {
                        newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {self.amount = filtered}
                        if newValue.count > 10 {
                            self.amount.removeLast()
                        }
                    }
                .navigationBarItems(trailing:
                Button(action: {
                    if serialNum != "" {
                let newItem = Item(context: viewContext)
                newItem.serialNum = self.serialNum
                self.amountInt = Int64(amount) ?? 1
                newItem.amount = self.amountInt
                newItem.itemid = UUID()
                newItem.creationDate = Date()
                newItem.isOnDeleted = false
                newItem.journalNum = self.journalNum
                do{
                    try viewContext.save()
                    print("item saved")
                    presentationMode.wrappedValue.dismiss()
                    }
                catch{
                    print(error.localizedDescription)
                }
                    }}, label: {
                Text("Добавить")
                    }) .disabled(serialNum.isEmpty || journalNum.isEmpty)
                )
            }.navigationBarTitle("Новый объект", displayMode: .inline)
        
    }
}
}

