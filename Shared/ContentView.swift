//
//  ContentView.swift
//  Shared
//
//  Created by Jorre Van Dyck on 14/02/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.device)
            .previewDevice("iPhone 13 Pro Max")
    }
}
