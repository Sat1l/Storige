//
//  DetailedView.swift
//  Storige
//
//  Created by Максим Сателайт on 31.01.2021.
//

import SwiftUI
import Combine

struct DetailedView: View {
    @EnvironmentObject var itemDetails: ItemProperties
    @State var items: [Any] = []
    @State var sharing = false
    @State var isViewing = true
    @State var amountText = ""
    let filter = CIFilter.qrCodeGenerator()
    var uuid: UUID?
    var uuidString: String? {return itemDetails.uuid?.uuidString}
    var body: some View {NavigationView{
        Form{
            Section(header: Text("Наименование: ")){
                TextField("Название", text: $itemDetails.serialNum)
                    .keyboardType(.default)
                    .onReceive(Just(itemDetails.serialNum)) { inputValue in
                                if inputValue.count > 100 {
                                self.itemDetails.serialNum.removeLast()
                                }
                    }
                    .transition(.opacity)
                    .disabled(isViewing)
            }
            Section(header: Text("Журнальный номер: ")){
                TextField("Журнальный номер", text: $itemDetails.journalNum)
                    .keyboardType(.default)
                    .onReceive(Just(itemDetails.journalNum)) { inputValue in
                                if inputValue.count > 30 {
                                    self.itemDetails.journalNum.removeLast()
                                }
                    }
                    .disabled(isViewing)
            }
//            Section(header: Text("Количество: ")){
//                TextField("Количество", value: $amountText, formatter: NumberFormatter())
//                    .keyboardType(.numberPad)
//                    .onReceive(Just(amountText))
//                    {
//                        newValue in
//                        let filtered = newValue.filter { "0123456789".contains($0) }
//                        if filtered != newValue {self.amountText = filtered}
//                        if newValue.count > 10 {
//                            self.amountText.removeLast()
//                        }
//                        itemDetails.amount = Int64(amountText) ?? 0
//                    }
//            }
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
        .navigationBarTitle(itemDetails.serialNum, displayMode: .inline)
        .navigationBarItems(leading:
                                Button(action:{isViewing.toggle()},label: {Text(isViewing == true ? "Изменить":"Готово")})
        )
    }
//    .onAppear(perform: {
//                amountText = String(itemDetails.amount)
//    })
    }
    func shareButton() {
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.last!.rootViewController!.present(av, animated: true, completion: nil)
        sharing.toggle()
    }
}

extension DetailedView
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
