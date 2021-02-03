//
//  NewItemSheet.swift
//  Storige
//
//  Created by Максим Сателайт on 08.12.2020.
//

import SwiftUI
import Combine
import CoreImage.CIFilterBuiltins

struct NewItemSheet: View
{    let filter = CIFilter.qrCodeGenerator()
    var uuid: UUID?
    var uuidString: String? {return uuid?.uuidString}
    @State var serialNum = ""
    @State var journalNum = ""
    @State var amount = ""
    @State var amountInt: Int64 = 1
    @State var items: [Any] = []
    @State var sharing = false
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
    func shareButton() {
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.last!.rootViewController!.present(av, animated: true, completion: nil)
        sharing.toggle()
    }
}

extension NewItemSheet
{
func createQrCodeImage(_ uuidString: String) -> UIImage{
            let data = Data(uuidString.utf8)
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 15, y: 15)
    if let qrCodeImage = filter.outputImage?.transformed(by: transform){
                if let qrCodeCGImage = CIContext().createCGImage(qrCodeImage, from: qrCodeImage.extent){
                    return UIImage(cgImage:  qrCodeCGImage)
                }
            }
                return UIImage()
    }
}
