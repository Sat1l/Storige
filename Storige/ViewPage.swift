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
	@Environment (\.presentationMode) var presentationMode
	@StateObject var itemDetails = ItemProperties()
	@State private var isEditing = false
	@State private var searchText = ""
	@State var sortedItems:[Item] = []
	@State var fetchedItems:[Item] = []
	@State var activeSheet: ActiveSheet?
	@State var uuidToPass = UUID()
	@State var selected = false
	var body: some View // главный вью
	{
		NavigationView{// обертка для невигейшн вью начало
			List{ // начало оформления списка
				if searchText == "" {
					ForEach(containers, id: \.self) { container in
						Section(header: Text(container.name!)) {
							if container.itemArray.isEmpty {
								Text("ничего нету")
							} else {
							ForEach(container.itemArray, id: \.self) { Item in
								Button(action: {
									itemDetails.serialNum = Item.serialNum ?? ""
									itemDetails.journalNum = Item.journalNum ?? ""
									itemDetails.amount = Item.amount
									itemDetails.uuid = Item.itemid
									uuidToPass = Item.itemid!
									activeSheet = .detailed
								}, label: {
								VStack(alignment: .leading){
									Text("\(Item.serialNum ?? "")")
										.font(.headline)
									Text("Журнальный номер: \(Item.journalNum ?? "отсутствует")")
										.font(.subheadline)
									Text("Кол-во: \(Item.amount)")
										.font(.subheadline)
								}})
								.swipeActions{Button("Удалить", role: .destructive){ withAnimation(.default, {viewContext.delete(Item); try?viewContext.save()})}}
							}
							}
						}
					}
				} else {
					ForEach(selected ? items.filter{$0.journalNum!.hasPrefix(searchText)} : items.filter{$0.serialNum!.hasPrefix(searchText)}, id: \.self) { Item in
						Button(action: {
								  itemDetails.serialNum = Item.serialNum ?? ""
								  itemDetails.journalNum = Item.journalNum ?? ""
								  itemDetails.amount = Item.amount
								  itemDetails.uuid = Item.itemid
								  uuidToPass = Item.itemid!
								  activeSheet = .detailed
							  }, label: {
							  VStack(alignment: .leading){
								  Text("\(Item.serialNum ?? "")")
									  .font(.headline)
								  Text("Журнальный номер: \(Item.journalNum ?? "отсутствует")")
									  .font(.subheadline)
								  Text("Кол-во: \(Item.amount)")
									  .font(.subheadline)
							  }})
							  .swipeActions{Button("Удалить", role: .destructive){ withAnimation(.default, {viewContext.delete(Item); try?viewContext.save()})}}
						  }
				}
			}// конец оформления списка
			.keyboardToolbar(height: 50) {
				Picker(selection: $selected, label: Text(""), content: {
					Text("название").tag(false)
					Text("журнальный номер").tag(true)
				})
					.pickerStyle(SegmentedPickerStyle())
					.background()
					.cornerRadius(7)
					.padding(.horizontal)
			}
			.searchable(text: $searchText/*, placement: .navigationBarDrawer(displayMode: .always)*/)
			.navigationBarTitle("Обзор", displayMode: .inline)
			.navigationBarItems(trailing: Button(action: {activeSheet = .newItem}, label: {Text("Добавить")}))
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
					DetailedView(uuid: uuidToPass)
						.environment(\.managedObjectContext, self.viewContext)
						.onDisappear(perform: {
							for item in sortedItems{ if uuidToPass == item.itemid{ editItem(item: item) } }
							updateArrays()
						})
				}// свитч отслеживающий какой показывать - новый или обзор конец
			} // конец шита с добавлением или обзором
		
		} // обертка для невигейшн вью конец
		.onAppear{updateArrays()}
		.onDisappear{updateArrays()}
		.environmentObject(itemDetails)
	}// конец главного вью

	func updateArrays(){
		sortedItems = items.sorted(by: {$0.serialNum! < $1.serialNum!})
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

// its a stackoverflow answer copy paste construction for toolbar on keyboard when searchbar is used
struct KeyboardToolbar<ToolbarView: View>: ViewModifier {
	@Environment(\.isSearching) var isSearching
	let height: CGFloat
	let toolbarView: ToolbarView
	init(height: CGFloat, @ViewBuilder toolbar: () -> ToolbarView) {
		self.height = height
		self.toolbarView = toolbar()
	}
	func body(content: Content) -> some View {
		ZStack(alignment: .bottom) {
			GeometryReader { geometry in
				VStack { content }
				.frame(width: geometry.size.width, height: geometry.size.height)
			}
			if isSearching { toolbarView.frame(height: self.height) }
		} .frame(maxWidth: .infinity, maxHeight: .infinity)
			
	}
}

extension View {
	func keyboardToolbar<ToolbarView>(height: CGFloat, view: @escaping () -> ToolbarView) -> some View where ToolbarView: View { modifier(KeyboardToolbar(height: height, toolbar: view)) }
}
