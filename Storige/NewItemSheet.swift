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
{
    @State var TypeOfView: UInt8 // 1 - new item | 2 - view item | 3 - edit item
    let filter = CIFilter.qrCodeGenerator()
    var uuid: UUID?
    var uuidString: String? {return uuid?.uuidString}
    @State var dateA: Date?
    @State var serialNum = ""
    @State var amount = ""
    @State var amountInt: Int64 = 1
    @State var items: [Any] = []
    @State var sharing = false
    let now = Date()
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    
    var body: some View
    {NavigationView{
            switch TypeOfView{
            case 1: //добавление нового объекта
            Form
            {
                TextField("Название", text: $serialNum)
                    .keyboardType(.default)
                    .onReceive(Just(serialNum)) { inputValue in
                                if inputValue.count > 100 {
                                    self.serialNum.removeLast()
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
                .navigationBarItems(trailing: Button(action: {
                let newItem = Item(context: viewContext)
                newItem.serialNum = self.serialNum
                self.amountInt = Int64(amount)!
                newItem.amount = self.amountInt
                newItem.itemid = UUID()
                newItem.creationDate = Date()
                newItem.isOnDeleted = true
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
            }.navigationBarTitle("Новый объект", displayMode: .inline)
            case 2: //детали об объекте
                Form{
                    Section(header: Text("Наименование: ")){Text(serialNum)}
                    Section(header: Text("Количество: ")){Text(String(amountInt))}
                Section(header: HStack{
                        Text("QR код")
                        Spacer()
                        Button(action: {
                            items.removeAll()
                            items.append(createQrCodeImage(uuidString!))
                            shareButton()
                        }, label: {
                                Text("Поделиться")
                                .foregroundColor(.blue)
                        })
                    }){
                    HStack{
                    Image(uiImage: createQrCodeImage(uuidString!))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                    }
                    .padding(.horizontal)
                    }
                }
                .navigationBarTitle(serialNum, displayMode: .inline)
            default:
                Text("hello")
            }
        
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
