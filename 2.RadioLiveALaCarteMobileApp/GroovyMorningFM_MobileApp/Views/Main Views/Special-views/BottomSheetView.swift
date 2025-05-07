//
//  BottomSheetView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import SwiftUI

struct BottomSheetView: View {
    
    @ObservedObject var bigModel = BigModel.shared
    @Binding var offsetY: CGFloat
    let minHeight: CGFloat
    let maxHeight: CGFloat
    var programs: [Program]
    
    var body: some View {
        VStack {

            List {
                ForEach(programs.indices, id: \.self) { index in
                    Text("\(programs[index].radioName)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(  (index == bigModel.currentProgramIndex) ? .bold : .regular)
                        .onTapGesture {
                            if (programs[index].isProgramAvailable() || programs[index].isInLive()) {
                                
                                let result = bigModel.verifierValeur(index: index)
                                
                                if (result == 1) {
                                    bigModel.currentView = .MultipleAudiosPlayer
                                }
                                
                                if (result == 2) {
                                    bigModel.currentView = .LiveAudioPlayer
                                }
                                
                            }
                        }
                }
            }
            .frame(height: maxHeight - 50)
        }
        .frame(height: maxHeight)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
        .offset(y: offsetY)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = offsetY + value.translation.height
                    offsetY = min(max(newOffset, minHeight), maxHeight)
                }
                .onEnded { value in
                    let midPoint = (minHeight + maxHeight) / 2
                    offsetY = offsetY > midPoint ? maxHeight : minHeight
                }
        )
        .animation(.spring(), value: offsetY)
    }
}
