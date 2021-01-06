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
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var uuid: UUID?
    var uuidString: String? {return uuid?.uuidString}
    @State var serialNum = ""
    @State var amount = ""
    @State var amountInt: Int64 = 1
    @State var items: [Any] = []
    @State var sharing = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    
    var body: some View
    {NavigationView{
            switch TypeOfView{
            case 1:
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
                        if filtered != newValue {self.amount = filtered}
                    }
                .navigationBarItems(trailing: Button(action: {
                let newItem = Item(context: viewContext)
                newItem.serialNum = self.serialNum
                self.amountInt = Int64(amount)!
                newItem.amount = self.amountInt
                newItem.itemid = UUID()
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
            case 2:
                Form{
                Text("Наименование: \(serialNum)")
                Text("Кол-во: \(amountInt)")
                    Section(header: HStack{
                        Text("QR код")
                        Spacer()
                        Button(action: {
                            items.removeAll()
                            items.append(createQrCodeImage(uuidString!))
                            sharing.toggle()
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
                    }
                }
                .navigationBarTitle("Детали", displayMode: .inline)
                .sheet(isPresented: $sharing, content:{
                    ShareSheet(items: items)
                })
            default:
                Text("hello")
            }
        
    }
}
}

extension NewItemSheet
{
func createQrCodeImage(_ uuidString: String) -> UIImage{
            let data = Data(uuidString.utf8)
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 15, y: 15)
    if let qrCodeImage = filter.outputImage?.transformed(by: transform){
                if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent){
                    return UIImage(cgImage:  qrCodeCGImage)
                }
            }
                return UIImage()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
