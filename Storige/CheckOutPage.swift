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
    @State var showingRestoringAlert = false
    @State var uuidToPass = UUID()
    @State var ocherednoySpisokBl:[Item] = []
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
                guard var uuid = UUID(uuidString: code) else { return }
                uuidToPass = uuid
                for Item in ocherednoySpisokBl{
                    if uuid == Item.itemid{
                        if Item.isOnDeleted == true {
                            showingRestoringAlert = true
                        } else {
                            hernya.sharedUuid = Item.itemid
                            hernya.sharedSerialNum = Item.serialNum ?? ""
                            hernya.sharedJournalNum = Item.journalNum ?? ""
                            hernya.sharedAmount = Item.amount
                            showingActionSheet = true
                            break}
                        }
                    }
            case .failure(let error):
                print(error.localizedDescription)
            }}
        Image(systemName: "viewfinder")
            .resizable()
            .font(Font.title.weight(.ultraLight))
            .frame(width: 200, height: 200)
        }
        .onAppear{
            ocherednoySpisokBl = items.sorted(by: {$0.serialNum! < $1.serialNum!})
        }
        .alert(isPresented: $showingRestoringAlert) {
            Alert(title: Text("Восстановить объект?"), message: Text("Данный предмет сейчас находится в списке удалённых, чтобы продолжить, необходимо вернуть его в базу"),primaryButton: .default(Text("Отмена"), action: {print("peepee poopoo")}) ,secondaryButton: .default(Text("Восстановить"), action: {
                for item in ocherednoySpisokBl{
                    if uuidToPass == item.itemid{
                        recoverItem(item: item)
                        }
                    }
            }))
        }
        .actionSheet(isPresented: $showingActionSheet){
            ActionSheet(title: Text(hernya.sharedSerialNum), message: Text("Выберите действие"), buttons:[
                .default(Text("Информация")){showFoundItemSheet = true},
                .destructive(Text("удалить")){
                    print("da")
                    },
                .cancel()
            ])
        }
        .sheet(isPresented: $showFoundItemSheet, content: {
                DetailedView()})
        }
    func recoverItem(item: Item) {
        viewContext.performAndWait {
            item.isOnDeleted = false
            try? viewContext.save()
        }
    }
}
