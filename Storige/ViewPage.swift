//
//  ViewPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//

import SwiftUI
import CoreData

enum ActiveSheet: Identifiable { // ответственно за переключение шитов
    case first, second
    var id: Int {hashValue}
}

struct ViewPage: View{ // начало главной структуры
    
    @State var activeSheet: ActiveSheet?
    @State var sortSheet = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.serialNum, ascending: true)])
    public var items: FetchedResults<Item>
    @State var sortedItems:[Item] = []
    @State var fetchedItems:[Item] = []
    @State var typeOfSorting: Int8 = 1
    
    var body: some View // главный вью
    {
        NavigationView{ // обертка для невигейшн вью начало
            List{ // начало оформления списка
                ForEach(sortedItems) {  Item in // для каждого предмета в списке SortedItems применяем эти оформления
                    Button(action: { //начало действий при нажатии кнопки
                        activeSheet = .second // вызываем шит с подробностями об объекте
                        hernya.sharedUuid = Item.itemid
                        hernya.sharedSerialNum = Item.serialNum ?? ""
                        hernya.sharedAmount = Item.amount
                    }, label: //конец действий при нажатии кнопки и начало лейбла
                    {
                    VStack(alignment: .leading){ //визуальная оболочка для кнопки
                        Text("\(Item.serialNum ?? "")")
                            .font(.headline)
                        Text("Кол-во: \(Item.amount)")
                            .font(.subheadline)
                        Text("Айдишник: \(Item.itemid!)")
                            .font(.subheadline)
                        Text("Удалено?: \(String(Item.isOnDeleted))")
                            .font(.subheadline)
                    }.frame(height: 70)// конец визуальной оболочки для кнопки и модификатор с ограничителем высоты
                    }/*конец лейбла*/ ) /*конец кнопки*/ } /*конец оформлений*/
                .onDelete { indexSet in //отклик и обработка удаления предмета в списке начало
                    for index in indexSet {
                        updateOrder(item: sortedItems[index])
                        updateArrays()
                        }
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                } //отклик и обработка удаления предмета в спике конец
            } // конец оформления списка
            .listStyle(PlainListStyle())//модификатор для списка
            .navigationBarTitle("Обзор", displayMode: .automatic)//настройки для топ бара навигации
            .navigationBarItems(leading: Button(action:{sortSheet.toggle()},label: {Text("Сортировка")}),//первая строчка кнопки в топ баре добавления нового предмета
            trailing: Button(action: {activeSheet = .first}, label: {Image(systemName: "plus.circle").imageScale(.large)}))//вторая строчка кнопки в топ баре добавления нового предмета
            .sheet(item: $activeSheet) { item in //шит с добавлением, или же обзором предмета
                switch item { // свитч отслеживающий какой показывать - новый или обзор начало
                case .first: // добавление предмета
                    NewItemSheet(TypeOfView: 1)
                        .onDisappear(perform: {
                            updateArrays()
                        })
                case .second: // обзор предмета
                    NewItemSheet(TypeOfView: 2, uuid: hernya.sharedUuid, serialNum: hernya.sharedSerialNum, amountInt: hernya.sharedAmount)
                }// свитч отслеживающий какой показывать - новый или обзор конец
            } // конец шита с добавлением или обзором
            .actionSheet(isPresented: $sortSheet) { //ЭкшонЩит с типами сортировок
                ActionSheet(title: Text("Сортировать по"), buttons: [
                    .default(Text("Кол-во возрастание")) {forSorting(Type: 1)},
                    .default(Text("Кол-во убывание")) {forSorting(Type: 2)},
                    .default(Text("По Алфавиту")) {forSorting(Type: 3)},
                    .cancel()
                ])
            } // конец экшон щита
        } // обертка для невигейшн вью конец
        .onAppear{ // инициализируем списки и сортируем при запуске
            updateArrays()
        } // конец инициализации списков
    }// конец главного вью
    func forSorting(Type: Int){ // функция для сортировки отображаемого на экране списка начало
        switch Type{ // свитч для определения типа сортировки начало
        case 1: // возрастание количества
            typeOfSorting = 1
            sortedItems = items.filter{$0.isOnDeleted == false}.sorted(by: {$0.amount < $1.amount})
        case 2: // убывание количества
            typeOfSorting = 2
            sortedItems = items.filter{$0.isOnDeleted == false}.sorted(by: {$0.amount > $1.amount})
        case 3: //убывание по алфавиту
            typeOfSorting = 3
            sortedItems = items.filter{$0.isOnDeleted == false}.sorted(by: {$0.serialNum! < $1.serialNum!})
        default:
            print("yopta")
        }//свитч для определения типа сортировки конец
    }// функция для сортировки отображаемого на экране списка конец
    func updateOrder(item: Item) {
        print(item)
        let BoughtToggle = true
        viewContext.performAndWait {
            item.isOnDeleted = BoughtToggle
            try? viewContext.save()
        }
    }
    func updateArrays(){
        fetchedItems = items.sorted(by: {$0.serialNum! < $1.serialNum!})
        sortedItems = fetchedItems.filter{$0.isOnDeleted == false}
        hernya.deletedItemsList = items.filter{$0.isOnDeleted == true}
    }
} // конец главной структуры

struct hernya{ // херня начало
    static var sharedUuid: UUID?
    static var sharedSerialNum = ""
    static var sharedAmount: Int64 = 1
    static var deletedItemsList:[Item] = []
} // херня конец
