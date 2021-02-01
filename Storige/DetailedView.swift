//
//  DetailedView.swift
//  Storige
//
//  Created by Максим Сателайт on 31.01.2021.
//

import SwiftUI

struct DetailedView: View {
    let filter = CIFilter.qrCodeGenerator()
    var uuid: UUID?
    var uuidString: String? {return uuid?.uuidString}
    @State var serialNum = ""
    @State var journalNum = ""
    @State var amount = ""
    @State var amountInt: Int64 = 1
    @State var items: [Any] = []
    @State var sharing = false
    var body: some View {NavigationView{
        Form{
            Section(header: Text("Наименование: ")){Text(serialNum)}
            Section(header: Text("Журнальный номер: ")){Text(journalNum)}
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
    }
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
