//
//  QrCodeGen.swift
//  Storige
//
//  Created by Максим Сателайт on 09.12.2020.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QrCodeGen : View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var uuid: UUID
    var itemSerial: String
    var itemAmount: Int16
    var uuidString: String {return uuid.uuidString}
    var body : some View {
        Form{
        Text("Наименование: \(itemSerial)")
        Text("Кол-во: \(itemAmount)")
            Section(header: Text("персональный QR код")){
            HStack{
            Spacer()
            Image(uiImage: createQrCodeImage(uuidString))
                .interpolation(.none)
                .resizable()
                .frame(width: 250, height: 250, alignment: .center)
            Spacer()
            }
            }
        }
    }
    
    func createQrCodeImage(_ uuidString: String) -> UIImage{
        let data = Data(uuidString.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let qrCodeImage = filter.outputImage{
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent){
                return UIImage(cgImage:  qrCodeCGImage)
            }
        }
            return UIImage()
    }
    
}
