//
//  SettingsPage.swift
//  Storige
//
//  Created by Максим Сателайт on 03.12.2020.
//

import SwiftUI
import MessageUI

struct SettingsPage: View
{
    @State private var isShareSheetShowing = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    @State private var showShareSheet = false
    var body: some View
    {
        NavigationView
        {
            Form {
            NavigationLink(
                destination: SortView() .navigationBarTitle("Сортировка по", displayMode: .automatic),
                label: {Text("Сортировка по")})
                Section{
                    Button(action: {self.isShowingMailView.toggle()}){Text("Связаться с разработчиком")}
                        .disabled(!MFMailComposeViewController.canSendMail())
                        .sheet(isPresented: $isShowingMailView) {MailView(result: self.$result)}
                    Button(action: {self.showShareSheet = true}){Text("Рассказать друзьям")}}
                Text("Выйти из аккаунта").foregroundColor(.red)
            }.navigationBarTitle("Настройки", displayMode: .automatic)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["Попробуй новое приложение Storige для организации своих вещей! Ссылка в AppStore:"])
            
        }
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
