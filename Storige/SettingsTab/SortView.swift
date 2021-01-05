//
//  SortView.swift
//  Storige
//
//  Created by Максим Сателайт on 06.12.2020.
//

import Foundation
import SwiftUI

struct SortView: View {
    var body: some View {
        List{
            HStack{Text("По алфавиту"); Image(systemName: "textformat")}
            HStack{Text("По количеству содержимого"); Image(systemName: "arrow.up")}
            HStack{Text("По количеству содержимого"); Image(systemName: "arrow.down")}
        }
    }
}
