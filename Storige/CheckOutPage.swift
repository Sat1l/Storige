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
    @State var showFoundItemSheet = false
    @State var showingActionSheet = false
    @State var nameToPass: String = ""
    @State var amountToPass: Int16 = 0
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Item.itemid, ascending: true)
    ])
    var items: FetchedResults<Item>
    var body: some View {

        ZStack{VStack{ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 280, height: 40, alignment: .center)
                Text("найдите код для сканирования")
                    .font(.headline)
                    .foregroundColor(Color.white)
                }.padding(.top,50)
                Spacer()
            }
        CodeScannerView(codeTypes: [.qr], simulatedData: "79CF01DB-8FA8-4841-A745-97F83449ED77") { result in
            switch result {
            case .success(let code):
                print(code)
                let uuid = UUID(uuidString: code)
                for Item in items{
                    if uuid == Item.itemid{
                        self.nameToPass = Item.serialNum!
                        self.amountToPass = Item.amount
                        showingActionSheet = true
                        break}
                    else{}
                    }
            case .failure(let error):
                print(error.localizedDescription)
            }}
        Image(systemName: "viewfinder")
            .resizable()
            .font(Font.title.weight(.ultraLight))
            .frame(width: 200, height: 200)
        }
        .actionSheet(isPresented: $showingActionSheet){
            ActionSheet(title: Text(nameToPass), message: Text("Выберите действие"), buttons:[
                .default(Text("Информация")){showFoundItemSheet = true},
                .cancel()
            ])
        }
        .sheet(isPresented: $showFoundItemSheet, content: {
            FoundItem(itemSerial: nameToPass, itemAmount: amountToPass)})
        }
}
