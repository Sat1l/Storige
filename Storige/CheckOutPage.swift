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
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Item.itemid, ascending: true)
    ])
    var items: FetchedResults<Item>
    @State var SortedItems:[Item] = []
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
                var uuid = UUID(uuidString: code)
//                let firstLetter = Character(String(code.prefix(1)))
//                switch firstLetter.isNumber {
//                case true:
//                    firstLetter.wholeNumberValue! >= 5 ? print("decrease number") : print("increase number")
//                case false:
//                    firstLetter.uppercased() <= "N" ? print("increase alphabett") : print("decrease alphabet")
//                }
                for Item in items{
                    if uuid == Item.itemid{
                        hernya.sharedUuid = Item.itemid
                        hernya.sharedSerialNum = Item.serialNum ?? ""
                        hernya.sharedAmount = Item.amount
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
            ActionSheet(title: Text(hernya.sharedSerialNum), message: Text("Выберите действие"), buttons:[
                .default(Text("Информация")){showFoundItemSheet = true},
                .cancel()
            ])
        }
        .sheet(isPresented: $showFoundItemSheet, content: {
                NewItemSheet(TypeOfView: 2, uuid: hernya.sharedUuid, serialNum: hernya.sharedSerialNum, amountInt: hernya.sharedAmount)})
        }
}
