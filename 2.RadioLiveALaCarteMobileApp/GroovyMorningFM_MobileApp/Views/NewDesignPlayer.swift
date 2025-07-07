//
//  NewDesignPlayer.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 06/07/2025.
//

import SwiftUI

struct NewDesignPlayer: View {
    var body: some View {
        
        VStack {
            
            HStack {
                VStack(alignment: .leading) {
                    Text("France Inter")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("9:01 - 9:14")
                        .font(.largeTitle)
                        .foregroundStyle(Color.gray)
                    HStack {
                        Image(systemName: "hand.thumbsdown")
                            .font(.largeTitle)
                        Image(systemName: "hand.thumbsup")
                            .font(.largeTitle)
                    }
                }
                Spacer()
            }.padding(.horizontal)
            
            Spacer()
            
            Image("400x400_sc_le-billet-de-daniel-morin")
            
            Spacer()
            
            HStack(spacing: 5) {
                ForEach(["backward.end.fill", "pause", "forward.end.fill"], id: \.self) { icon in
                    GeometryReader { geometry in
                        let side = geometry.size.width
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.2))
                            Image(systemName: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: side * 0.3, height: side * 0.3)
                        }
                        .frame(width: side, height: side)
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
                        
            HStack {
                Text("0:00:00")
                Spacer()
                Text("0:14:56")
            }.padding(.horizontal)
                        
        }
    }
}

#Preview {
    NewDesignPlayer()
}
