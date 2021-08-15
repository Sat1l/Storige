//
//  DetailedView.swift
//  Storige
//
//  Created by Максим Сателайт on 31.01.2021.
//

import CoreImage.CIFilterBuiltins
import SwiftUI
import Combine

struct DetailedView: View {
	@Environment (\.presentationMode) private var presentationMode
    @EnvironmentObject var itemDetails: ItemProperties
	let filter = CIFilter.qrCodeGenerator()
	@State var items: [Any] = []
	@State var isChanged = false
	@State var sharing = false
    @State var amountText = ""
	var uuid: UUID?
	var uuidString: String? {return uuid?.uuidString}
	
    var body: some View {NavigationView{
        Form{
            Section(header: Text("Наименование: ")){
                TextField("Название", text: $itemDetails.serialNum)
                    .keyboardType(.default)
                    .onReceive(Just(itemDetails.serialNum)) { inputValue in
                                if inputValue.count > 100 {
                                self.itemDetails.serialNum.removeLast()
                                }
                    }.onChange(of: itemDetails.serialNum, perform: { value in if itemDetails.serialNum == hernya2o.originalSerialNum && itemDetails.journalNum == hernya2o.originalJournalNum { isChanged = false } else { isChanged = true }})
            }
			
            Section(header: Text("Журнальный номер: ")){
                TextField("Журнальный номер", text: $itemDetails.journalNum)
                    .keyboardType(.default)
                    .onReceive(Just(itemDetails.journalNum)) { inputValue in if inputValue.count > 30 { self.itemDetails.journalNum.removeLast() } }
            }.onChange(of: itemDetails.journalNum, perform: { value in if itemDetails.serialNum != hernya2o.originalSerialNum || itemDetails.journalNum != hernya2o.originalJournalNum { isChanged = false } else { isChanged = true }
            })
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
			Section(header: HStack{ Text("qr код"); Spacer(); Button("поделиться"){print("zaglushka")}}){
				Image(uiImage: createQrCodeImage(uuidString!))
								.interpolation(.none)
								.resizable()
								.scaledToFit()
			}
        }
        .navigationBarTitle(itemDetails.serialNum, displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action:{
										print("penis sobaki👍🏿")
										presentationMode.wrappedValue.dismiss()
								},label: { Text(isChanged == true ? "Сохранить":"Готово")}))
    }
	.onAppear(perform: { hernya2o.originalSerialNum = itemDetails.serialNum; hernya2o.originalJournalNum = itemDetails.journalNum })
    }
	func createQrCodeImage(_ uuidString: String) -> UIImage{
		let data = Data(uuidString.utf8)
		filter.setValue(data, forKey: "inputMessage")
		let transform = CGAffineTransform(scaleX: 15, y: 15)
		if let qrCodeImage = filter.outputImage?.transformed(by: transform){ if let qrCodeCGImage = CIContext().createCGImage(qrCodeImage,
		from: qrCodeImage.extent){ return UIImage(cgImage:  qrCodeCGImage) }}
		return UIImage()
		}
}

struct hernya2o{
    static var originalSerialNum: String = ""
    static var originalJournalNum: String = ""
}
