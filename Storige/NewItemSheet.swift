//
//  NewItemSheet.swift
//  Storige
//
//  Created by Максим Сателайт on 08.12.2020.
//

import SwiftUI
import Combine

class ContainerName: ObservableObject{
	@Published var containerName = String()
}

struct NewItemSheet: View{
	@StateObject var containerName = ContainerName()
	@State var sheesh = false
	@State var isPickerDisplayed = false
	@State var pickedContainer = ""
    @State var serialNum = ""
    @State var journalNum = ""
    @State var amount = ""
    @State var amountInt: Int64 = 1
	@FetchRequest(entity: Container.entity(), sortDescriptors: []) var containers: FetchedResults<Container>
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    var body: some View
    {NavigationView{
		ZStack{
            Form
            {
                TextField("Название", text: $serialNum)
					.onTapGesture { isPickerDisplayed = false }
                    .keyboardType(.default)
                    .onReceive(Just(serialNum)) { inputValue in
                                if inputValue.count > 50 {
                                    self.serialNum.removeLast()
                                }
                    }

                TextField("Журнальный номер", text: $journalNum)
					.onTapGesture { isPickerDisplayed = false }
                    .keyboardType(.default)
                    .onReceive(Just(journalNum)) { inputValue in
                                if inputValue.count > 30 {
                                    self.journalNum.removeLast()
                                }
                    }
                TextField("Количество", text: $amount)
					.onTapGesture { isPickerDisplayed = false }
                    .keyboardType(.numberPad)
                    .onReceive(Just(amount))
                    {
                        newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {self.amount = filtered}
                        if newValue.count > 10 {
                            self.amount.removeLast()
                        }
                    }
				Button(pickedContainer == "" ? "отсутствует":pickedContainer){ killkb(); isPickerDisplayed = true }
				}
				if isPickerDisplayed {
				VStack(spacing: 0){
				Spacer()
				Divider()
					HStack{
						Button("добавить новую"){
							killkb()
							sheesh.toggle()
							print("im depressed")
						}
						Spacer()
						Button("Готово"){
							isPickerDisplayed = false
							print(pickedContainer)
						}
					}
					.foregroundColor(.blue)
					.padding(.all)
					.background(Color(UIColor.label).colorInvert())
				Picker(selection: $pickedContainer, label: Text("")) {
					Text("none").tag("zhopa")
					ForEach(containers, id: \.name) { container in
						Text(container.name!).tag(container.name!)
					}
				}.pickerStyle(WheelPickerStyle())
				.frame(maxWidth: .infinity)
				.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
				.onChange(of: pickedContainer, perform: { value in print(pickedContainer) })
			}
				.transition(.move(edge: .bottom))
				.animation(.default)
			}
	}
		.navigationBarItems(leading: Button("Отмена"){
			containerName.containerName = String()
			presentationMode.wrappedValue.dismiss()
		}, trailing:
			Button("Добавить"){
				if serialNum != "" {
					let newItem = Item(context: viewContext)
					newItem.serialNum = self.serialNum
					self.amountInt = Int64(amount) ?? 1
					newItem.amount = self.amountInt
					newItem.itemid = UUID()
					newItem.creationDate = Date()
					newItem.isOnDeleted = false
					newItem.journalNum = self.journalNum
					newItem.container = containers.filter{$0.name!.hasPrefix(pickedContainer)}.first
					do {
						try viewContext.save()
						print("item saved")
						presentationMode.wrappedValue.dismiss()
					}
					catch { print(error.localizedDescription) }
				}}
			.disabled(serialNum.isEmpty || journalNum.isEmpty)
		)
		.navigationBarTitle("Новый объект", displayMode: .large)
    }
	.sheet(isPresented: $sheesh, content: {
		NewFamilySheet(containerName: containerName)
			.environment(\.managedObjectContext, self.viewContext)
			.onDisappear(){ if pickedContainer == "" { pickedContainer = "отсутствует" } }
	})
}
	func killkb(){ UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
}

struct NewFamilySheet: View {
	@Environment (\.presentationMode) private var presentationMode
	@Environment(\.managedObjectContext) private var viewContext
	@ObservedObject var containerName: ContainerName
	var body: some View {
		NavigationView{
		Form{
		TextField("Название", text: $containerName.containerName)
			.keyboardType(.default)
			.onReceive(Just(containerName.containerName)) { inputValue in
				if inputValue.count > 50 { self.containerName.containerName.removeLast() }
			}
		}
			.navigationBarTitle("Новый контейнер", displayMode: .large)
		.navigationBarItems(leading: Button("Отмена"){
			containerName.containerName = String()
			presentationMode.wrappedValue.dismiss()
		}, trailing:
			Button("Добавить"){
				let newContainer = Container(context: viewContext)
				newContainer.name = containerName.containerName
				newContainer.containerid = UUID()
				do {
					try viewContext.save()
					print("item saved")
					presentationMode.wrappedValue.dismiss()
				}
				catch { print(error.localizedDescription) }
				presentationMode.wrappedValue.dismiss()
				} .disabled(containerName.containerName.isEmpty)
			)
		
		}
}
}
