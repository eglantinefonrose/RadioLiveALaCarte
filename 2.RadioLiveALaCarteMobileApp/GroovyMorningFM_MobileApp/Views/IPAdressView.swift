//
//  IPAdressView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 28/02/2025.
//

import SwiftUI

struct IPAdressView: View {
    
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @State var ipAddress: String = BigModel.shared.ipAdress
    
    var body: some View {
        
        VStack(spacing: 0) {
            VStack {
                
                Spacer()
                
                Text("L'adresse IP du serveur")
                    .bold()
                
                TextField("Nouvelle adresse IP", text: $ipAddress)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray)
                    )
                
                Spacer()
                
            }.padding(20)
            
            Spacer()
            
            HStack {
                Spacer()
                Text("Valider")
                    .padding(20)
                    .foregroundColor(.white)
                    .bold()
                Spacer()
            }.background(Color.purple)
            .onTapGesture {
                bigModel.ipAdress = ipAddress
                bigModel.currentView = .ProgramScreen
            }

            
        }.edgesIgnoringSafeArea(.all)
        
    }
}

#Preview {
    IPAdressView()
}
