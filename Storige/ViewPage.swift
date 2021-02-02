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
    @State private var showCancelButton: Bool = false
    @State private var searchText = ""
    
    var body: some View // главный вью
    {
        NavigationView{// обертка для невигейшн вью начало
            VStack{
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")

                        TextField("search", text: $searchText, onEditingChanged: { isEditing in
                            self.showCancelButton = true
                        }, onCommit: {
                            print("onCommit")
                        }).foregroundColor(.primary)

                        Button(action: {
                            self.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)

                    if showCancelButton  {
                        Button("Cancel") {
                                UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                                self.searchText = ""
                                self.showCancelButton = false
                        }
                        .foregroundColor(Color(.systemBlue))
                    }
                }
                .padding(.horizontal)
                .navigationBarHidden(showCancelButton)
            List{ // начало оформления списка
                ForEach(sortedItems.filter{$0.serialNum!.hasPrefix(searchText) || searchText == ""}) {  Item in // для каждого предмета в списке SortedItems применяем эти оформления
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
                    }// конец визуальной оболочки для кнопки и модификатор с ограничителем высоты
                    } /*конец лейбла*/ ) /*конец кнопки*/ } /*конец оформлений*/
                .onDelete { indexSet in //отклик и обработка удаления предмета в списке начало
                    for index in indexSet {
                        updateOrder(item: sortedItems[index])
                        }
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    updateArrays()
                } //отклик и обработка удаления предмета в спике конец
            } // конец оформления списка
            }
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
                    DetailedView(uuid: hernya.sharedUuid, serialNum: hernya.sharedSerialNum, amountInt: hernya.sharedAmount)
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
        .onAppear{updateArrays()} // конец инициализации списков
        .onDisappear{updateArrays()}
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
        let BoughtToggle = true
        viewContext.performAndWait {
            item.isOnDeleted = BoughtToggle
            try? viewContext.save()
        }
    }
    func updateArrays(){
        fetchedItems = items.sorted(by: {$0.serialNum! < $1.serialNum!})
        sortedItems = fetchedItems.filter{$0.isOnDeleted == false}
    }
} // конец главной структуры

struct hernya{ // херня начало
    static var sharedUuid: UUID?
    static var sharedSerialNum = ""
    static var sharedAmount: Int64 = 1
} // херня конец

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
