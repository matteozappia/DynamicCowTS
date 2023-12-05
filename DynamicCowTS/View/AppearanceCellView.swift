//
//  AppearanceCellView.swift
//  DynamicCowTS
//
//  Created by zeph on 28/11/23.
//

import SwiftUI

struct AppearanceCellView: View {
    
    // MARK: bindings
    @Binding var checkedPro: Bool
    @Binding var checkedProMax: Bool
    
    // MARK: view
    var body: some View {
        List{
            Section {
                HStack(spacing: 10){
                    VStack(alignment: .center, spacing: 10){
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 120))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.7))
                    
                        Text("iPhone 14\nPro")
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: checkedPro ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(checkedPro ? .white : .secondary)
                            .font(.title)
                            .padding([.horizontal, .top])
                                
                        
                    }//.padding()
                    .onTapGesture {
                        withAnimation{
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            checkedProMax = false
                            self.checkedPro = true
                        }
                    }
                    
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 10){
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 120))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.7))
                           
                        Text("iPhone 14\nPro Max")
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: checkedProMax ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(checkedProMax ? .white : .secondary)
                            .font(.title)
                            .padding([.horizontal, .top])
                                   
                        
                    }//.padding()
                    .onTapGesture {
                        withAnimation{
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            checkedPro = false
                            self.checkedProMax = true
                        }
                    }
                    
                }
                .padding()
            } header: {
                Text("Layout")
            } footer: {
                Text("Choose between the iPhone 14 Pro and the iPhone 14 Pro Max layout before start.")
                    .padding(.top)
            }

        }
        .listStyle(.insetGrouped)
        .listRowSeparator(.hidden)
        .scrollDisabled(true)
    }
    
}

/*
struct AppearanceCellView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceCellView()
    }
}
*/
