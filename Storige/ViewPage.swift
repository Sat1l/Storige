//
//  ViewPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//
import SwiftUI
import CoreData

enum ActiveSheet: Identifiable {
	case newItem, detailed
	var id: Int {hashValue}
}

class ItemProperties: ObservableObject {
	@Published var uuid: UUID?
	@Published var serialNum = ""
	@Published var amount: Int64 = 1
	@Published var journalNum = ""
}

struct ViewPage: View{ // начало главной структуры
	@FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.serialNum, ascending: true)]) public var items: FetchedResults<Item>
	@FetchRequest(entity: Container.entity(), sortDescriptors: []) var containers: FetchedResults<Container>
	@Environment(\.managedObjectContext) private var viewContext
	@StateObject var itemDetails = ItemProperties()
	@State private var isPickerDisplayed = false
	@State private var isEditing = false
	@State private var searchText = ""
	@State var sortedItems:[Item] = []
	@State var fetchedItems:[Item] = []
	@State var activeSheet: ActiveSheet?
	@State var uuidToPass = UUID()
	@State var sortSheet = false
	@State var selected = false
	@State var age = 0
	var body: some View // главный вью
	{
		NavigationView{// обертка для невигейшн вью начало
			ZStack{
			VStack{
			List{ // начало оформления списка
				VStack{
				HStack {
					TextField("Поиск", text: $searchText)
						.onTapGesture {
							self.isEditing = true
						}
						.padding(7)
						.padding(.horizontal, 25)
						.background(Color(.systemGray6))
						.cornerRadius(8)
						.overlay(
							HStack {
								Image(systemName: "magnifyingglass")
									.foregroundColor(.gray)
									.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
									.padding(.leading, 8)
							}
						)
						.padding(.horizontal, 10)
					if isEditing {
						Button(action: {
							self.isEditing = false
							self.searchText = ""
							UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
						}) {
							Text("Отменить")
								.foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
						}
						.padding(.trailing, 10)
						.transition(.move(edge: .trailing))
					}
				}
					if isEditing {
						Picker(selection: $selected, label: Text(""), content: {
							Text("Название").tag(false)
							Text("Журнальный номер").tag(true)
					}).pickerStyle(SegmentedPickerStyle())
					}
					
			}
				Button(""){
					print(items, containers)
				}
				ForEach(containers, id: \.self) { container in
					Section(header: Text(container.name!)) {
						if container.itemArray.isEmpty {
							Text("pusto")
						} else {
						ForEach(container.itemArray, id: \.self) { item in
						VStack{
							Text("\(item.serialNum ?? "")")
								.font(.headline)
							Text("Журнальный номер: \(item.journalNum ?? "отсутствует")")
								.font(.subheadline)
							Text("Кол-во: \(item.amount)")
								.font(.subheadline)
							}
						}
					}
					}
				}
//				ForEach( selected ? sortedItems.filter{$0.journalNum!.hasPrefix(searchText) || searchText == ""} : sortedItems.filter{$0.serialNum!.hasPrefix(searchText) || searchText == ""}) {  Item in // для каждого предмета в списке SortedItems применяем эти оформления
//					Button(action: { //начало действий при нажатии кнопки
//						itemDetails.serialNum = Item.serialNum ?? ""
//						itemDetails.journalNum = Item.journalNum ?? ""
//						itemDetails.amount = Item.amount
//						itemDetails.uuid = Item.itemid
//						uuidToPass = Item.itemid!
//						activeSheet = .detailed // вызываем шит с подробностями об объекте
//					}, label: //конец действий при нажатии кнопки и начало лейбла
//					{
//					VStack(alignment: .leading){ //визуальная оболочка для кнопки
//						Text("\(Item.serialNum ?? "")")
//							.font(.headline)
//						Text("Журнальный номер: \(Item.journalNum ?? "отсутствует")")
//							.font(.subheadline)
//						Text("Кол-во: \(Item.amount)")
//							.font(.subheadline)
//						Text("контейнер: \(Item.container.name)")
//							.font(.subheadline)
//					}// конец визуальной оболочки для кнопки и модификатор с ограничителем высоты
//					} /*конец лейбла*/ ) /*конец кнопки*/ } /*конец оформлений*/
//				.onDelete { indexSet in //отклик и обработка удаления предмета в списке начало
//					for index in indexSet {
//						updateOrder(item: sortedItems[index])
//						}
//					do {
//						try viewContext.save()
//					} catch {
//						print(error.localizedDescription)
//					}
//					updateArrays()
//				} //отклик и обработка удаления предмета в спике конец
			} // конец оформления списка
			.listStyle(PlainListStyle())//модификатор для списка
			}
		}
			.navigationBarTitle("Обзор", displayMode: .automatic)//настройки для топ бара навигации
			.navigationBarItems(leading: Button(action:{sortSheet.toggle()},label: {Text("Сортировка")}),
			trailing: Button(action: {activeSheet = .newItem}, label: {Text("Добавить")}))
			.navigationBarHidden(isEditing)
			.sheet(item: $activeSheet) { item in //шит с добавлением, или же обзором предмета
				switch item { // свитч отслеживающий какой показывать - новый или обзор начало
				case .newItem: // добавление предмета
					NewItemSheet()
						.environment(\.managedObjectContext, self.viewContext)
						.onDisappear(perform: {
							updateArrays()
						})
				case .detailed: // обзор предмета
					DetailedView()
						.environment(\.managedObjectContext, self.viewContext)
						.onDisappear(perform: {
							for item in sortedItems{
								if uuidToPass == item.itemid{
									editItem(item: item)
									}
								}
							updateArrays()
						})
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
		.environmentObject(itemDetails)
	}// конец главного вью
	func forSorting(Type: Int){ // функция для сортировки отображаемого на экране списка начало
		switch Type{ // свитч для определения типа сортировки начало
		case 1: // возрастание количества
			sortedItems = items.filter{$0.isOnDeleted == false}.sorted(by: {$0.amount < $1.amount})
		case 2: // убывание количества
			sortedItems = items.filter{$0.isOnDeleted == false}.sorted(by: {$0.amount > $1.amount})
		case 3: //убывание по алфавиту
			sortedItems = items.filter{$0.isOnDeleted == false}.sorted(by: {$0.serialNum! < $1.serialNum!})
		default:
			print("yopta")
		}//свитч для определения типа сортировки конец
	}// функция для сортировки отображаемого на экране списка конец
	func updateOrder(item: Item) {
		viewContext.performAndWait {
			item.isOnDeleted = true
			try? viewContext.save()
		}
	}

	func updateArrays(){
		fetchedItems = items.sorted(by: {$0.serialNum! < $1.serialNum!})
		sortedItems = fetchedItems.filter{$0.isOnDeleted == false}
	}

	func editItem(item: Item) {
		viewContext.performAndWait {
			item.serialNum = itemDetails.serialNum
			item.journalNum = itemDetails.journalNum
			item.amount = itemDetails.amount
			try? viewContext.save()
		}
	}

} // конец главной структуры
