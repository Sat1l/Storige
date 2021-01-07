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
    @State var showSortSheet = false
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
                    Button(action: {shareButton()}){Text("Рассказать друзьям")}}
                Text("Выйти из аккаунта").foregroundColor(.red)
            }.navigationBarTitle("Настройки", displayMode: .automatic)
        }
    }
    func shareButton() {
        isShareSheetShowing.toggle()
        let url = ["Попробуйте новое приложение для организации своих вещей - Storige!"]
        let av = UIActivityViewController(activityItems: url, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)

    }
}
