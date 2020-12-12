//
//  CheckOutPage.swift
//  Storige
//
//  Created by Максим Сателайт on 11.12.2020.
//

import SwiftUI
import CodeScanner
import CoreData

struct CheckOutPage: View {
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Item.itemid, ascending: true)
    ])
    var items: FetchedResults<Item>
    var body: some View {
        ZStack{
            VStack{
                ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 280, height: 40, alignment: .center)
                Text("найдите код для сканирования")
                    .font(.headline)
                    .foregroundColor(Color.white)
                }.padding(.top,50)
                Spacer()
            }
        CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
            switch result {
            case .success(var code):
                print(code)
                var uuid = UUID(uuidString: code)
                var existence: Int64 = 0
                for Item in items{
                    if uuid != Item.itemid{
                        existence += 0}else{existence += 1}}
                if existence == 1{
                    print("Est' pidoras")
                    self.showingAlert1 = true
                    }.alert(isPresented: $showingAlert1) {Alert(title: Text("One"), message: nil, dismissButton: .cancel())}
                elsedo {
                print("ne probil")
                    self.showingAlert2 = true
                    }
            case .failure(let error):
                print(error.localizedDescription)
            }}
        Image(systemName: "square.dashed")
            .resizable()
            .frame(width: 200, height: 200, alignment: .center)
        }
        
    }
}


struct CheckOutPage_Previews: PreviewProvider {
    static var previews: some View {
        CheckOutPage()
    }
}
