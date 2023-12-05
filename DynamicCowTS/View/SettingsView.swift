//
//  SettingsView.swift
//  DynamicCowTS
//
//  Created by zeph on 28/11/23.
//

import SwiftUI
import Foundation

struct SettingsView: View {
    
    // MARK: alerts
    @State var showPFAlert: Bool = false
    @State var showASAlert: Bool = false
    
    // MARK: variables
    @State var version: String = ""
    
    
    // MARK: env
    @Environment(\.openURL) var openURL
    
    
    // MARK: view
    var body: some View {
        NavigationStack{
                List{
                    
                    Section {
                        HStack {
                            Text("🍕")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                            VStack(alignment: .leading) {
                                Text("buy me a pizza")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("on buymeacoffee.com")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName:"arrow.up.forward.app.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            openURL(URL(string:"https://www.buymeacoffee.com/aboutzeph")!)
                        }
                        
                   
                        

                        HStack {
                            Text("☕️")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                            VStack(alignment: .leading) {
                                Text("buy me a coffee")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("on ko-fi.com")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName:"arrow.up.forward.app.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            openURL(URL(string:"https://ko-fi.com/aboutzeph")!)
                        }
                        
                    } header: {
                        Text("Donate")
                            .padding(.top, 2)
                    } footer: {
                        Text("Any donation is greatly appreciated, this would help me continue to develop these kinds of apps for free and open source.")
                    }
                    
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(version)
                                .foregroundColor(.secondary)
                        }
                        
                        
                    } header: {
                        Text("About")
                    } footer: {
                        //
                    }
                    
                    Section {
                        Button {
                            withAnimation{
                                showPFAlert = true
                            }
                        } label: {
                            Text("Restore plist file")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .alert("Are you sure?", isPresented: $showPFAlert) {
                            Button("Yes", role: .destructive) {
                                
                                // restore plist
                                //killMobileGestalt()
                                do {
                                    try FileManager.default.replaceItemAt(URL(fileURLWithPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"), withItemAt: URL(fileURLWithPath: "/var/mobile/Documents/.DynamicCowBackups/com.apple.MobileGestalt.plist"))
                                    
                                    try FileManager.default.replaceItemAt(URL(fileURLWithPath: "/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"), withItemAt: URL(fileURLWithPath: "/var/mobile/Documents/.DynamicCowBackups/com.apple.iokit.IOMobileGraphicsFamily.plist"))

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        respring()
                                    }
                                } catch {
                                    UIApplication.shared.alert(body: "There was an error restoring the plist file.\n\(error)")
                                }
                                
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("You are going to reset the plist file to its initial state.")
                        }
                        
                        Button {
                            withAnimation{
                                showASAlert = true
                            }
                        } label: {
                            Text("Reset app state")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .alert("Are you sure?", isPresented: $showASAlert) {
                            Button("Yes", role: .destructive) { UserDefaults.standard.resetAppState() }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("You are going to reset app current state.")
                        }


                    } header: {
                        Text("Troubleshoot")
                    } footer: {
                        Text("Normally the app should not corrupt the plist file, but in rare cases it can happen, especially if you have made changes manually through Filza / Santander, this can lead to an app crash when you try to enable or disable the Dynamic Island. To restore it to its initial state, click Restore plist file.\n\nIf the app thinks you have Dynamic Island turned on but it is disabled click on Reset app state.")
                    }

                    
                    Section{
                        HStack {
                            Button {
                                withAnimation {
                                    respring()
                                }
                                
                            } label: {
                                Text("Respring")
                                    .font(.headline)
                                    .foregroundColor(.cyan)
                            }
                            
                            Spacer()
                        }
                    }
            }
            .onAppear{
                version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
            }
            .navigationTitle("Settings")
        }
    }
    
    func respring(){
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        view.alpha = 0

        UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first!.windows.first!.addSubview(view)
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            view.alpha = 1
        })
        
        spawnRoot("\(Bundle.main.bundlePath)/killall", ["-9", "cfprefsd"], nil, nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            spawnRoot("\(Bundle.main.bundlePath)/killall", ["-9", "backboardd"], nil, nil)
        })
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
