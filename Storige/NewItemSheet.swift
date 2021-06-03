//
//  NewItemSheet.swift
//  Storige
//
//  Created by Максим Сателайт on 08.12.2020.
//

import SwiftUI
import Combine
import CoreImage.CIFilterBuiltins

class ContainerName: ObservableObject{
	@Published var containerName = String()
}


struct NewItemSheet: View{
	@StateObject var containerName = ContainerName()
	@State var sheesh = false
	@State var isPickerDisplayed = false
	@State var contlist = [String]()
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
                    .keyboardType(.default)
                    .onReceive(Just(serialNum)) { inputValue in
                                if inputValue.count > 100 {
                                    self.serialNum.removeLast()
                                }
                    }

                TextField("Журнальный номер", text: $journalNum)
                    .keyboardType(.default)
                    .onReceive(Just(journalNum)) { inputValue in
                                if inputValue.count > 30 {
                                    self.journalNum.removeLast()
                                }
                    }
                TextField("Количество", text: $amount)
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
				Button(pickedContainer == "" ? "Выберите контейнер":pickedContainer){
					UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
					isPickerDisplayed = true
				}
				}
				if isPickerDisplayed {
				VStack(spacing: 0){
				Spacer()
				Divider()
					HStack{
						Button("добавить новую"){
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
					ForEach(containers, id: \.name) { container in
						Text(container.name!).tag(container.name!)
					}
				}.pickerStyle(WheelPickerStyle())
				.frame(maxWidth: .infinity)
				.background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
			}
				.transition(.move(edge: .bottom))
				.animation(.default)
			}
	}
		.navigationBarItems(trailing:
		Button(action: {
			if serialNum != "" {
		let newItem = Item(context: viewContext)
		newItem.serialNum = self.serialNum
		self.amountInt = Int64(amount) ?? 1
		newItem.amount = self.amountInt
		newItem.itemid = UUID()
		newItem.creationDate = Date()
		newItem.isOnDeleted = false
		newItem.journalNum = self.journalNum
		newItem.container?.name = pickedContainer
		do{
			try viewContext.save()
			print("item saved")
			print(pickedContainer)
			presentationMode.wrappedValue.dismiss()
			}
		catch{
			print(error.localizedDescription)
		}
			}}, label: {
		Text("Добавить")
			}) .disabled(serialNum.isEmpty || journalNum.isEmpty)
		)
		.navigationBarTitle("Новый объект", displayMode: .inline)
		
    }

	.sheet(isPresented: $sheesh, content: {
		NewFamilySheet(containerName: containerName)
			.environment(\.managedObjectContext, self.viewContext)
			.onDisappear(){ contlist.append(containerName.containerName) }
	})
}
}

struct NewFamilySheet: View {
	@Environment (\.presentationMode) private var presentationMode
	@Environment(\.managedObjectContext) private var viewContext
	@ObservedObject var containerName: ContainerName
	var body: some View {
		TextField("Имя", text: $containerName.containerName)
			.keyboardType(.default)
			.onReceive(Just(containerName.containerName)) { inputValue in
				if inputValue.count > 100 { self.containerName.containerName.removeLast() }
			}
		Text("zhopa")
			.onTapGesture {
				let newContainer = Container(context: viewContext)
				newContainer.name = containerName.containerName
				presentationMode.wrappedValue.dismiss()
			}
	}
}

