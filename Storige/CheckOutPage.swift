//
//  CheckOutPage.swift
//  Storige
//
//  Created by Максим Сателайт on 11.12.2020.
//

import SwiftUI
import CodeScanner

struct CheckOutPage: View {
    var body: some View {
        ZStack{
        CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in
            switch result {
            case .success(let code):
                print(code)
            case .failure(let error):
                print(error.localizedDescription)
            }}
        Image(systemName: "square.dashed")
            .resizable()
            .frame(width: 250, height: 250, alignment: .center)
            .shadow(color: Color.black, radius: 10, x: 0, y: 0)
        }
        
    }
}


struct CheckOutPage_Previews: PreviewProvider {
    static var previews: some View {
        CheckOutPage()
    }
}
