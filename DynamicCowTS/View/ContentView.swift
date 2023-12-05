//
//  ContentView.swift
//  DynamicCowTS
//
//  Created by zeph on 28/11/23.
//

import SwiftUI
import Foundation

struct ContentView: View {

    // MARK: dynamic keys
    @AppStorage(DynamicKeys.isEnabled.rawValue) private var isEnabled: Bool = false
    @AppStorage(DynamicKeys.currentSet.rawValue) private var currentSet: Int = 0
    @AppStorage(DynamicKeys.originalDeviceSubType.rawValue) private var originalDeviceSubType: Int = 0


    // MARK: variables
    @State var checkedPro: Bool = false
    @State var checkedProMax: Bool = false
    @State var isDoing: Bool = false
    @State var shouldRedBarFix: Bool = false
    @State private var redBarValues: RedBarValues?

    // MARK: constants
    private let dynamicPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    private let resPath = "/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"

    // MARK: alerts
    @State var shouldAlertDeviceSubTypeError: Bool = false


    // MARK: view
    var body: some View {
        NavigationStack {
            VStack {
                AppearanceCellView(checkedPro: $checkedPro, checkedProMax: $checkedProMax)
                    .disabled(isEnabled)
                    .disabled(isDoing)
                    .opacity(isEnabled ? 0.8 : 1)
                    .opacity(isDoing ? 0.8 : 1)
                Spacer()
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()

                    if isEnabled {
                        // disable
                        if shouldRedBarFix{
                            setResolution()
                        }

                        withAnimation{
                            isDoing = true
                            isEnabled = false
                        }

                        replacePlistData()
                    } else {
                        // enable
                        if shouldRedBarFix{
                            setResolution()
                        }

                        withAnimation{
                            isDoing = true
                            isEnabled = true
                        }

                        replacePlistData()
                    }


                } label: {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 54)
                        .foregroundColor(.white.opacity(0.9))
                        .overlay {
                            if !isDoing{
                                Text(isEnabled ? "Disable" : "Enable")
                                    .foregroundColor(.black)
                                    .bold()
                            }else{
                                ProgressView()
                                    .tint(.black)
                            }
                        }
                        .padding()
                }
                .disabled(checkedPro || checkedProMax ? false : true)
                .disabled(isDoing)
                .opacity(checkedPro || checkedProMax ? 1 : 0.8)
                .opacity(isDoing ? 0.8 : 1)
                .padding(.bottom)


            }
            .navigationTitle("DynamicCow")
            .toolbar {
                
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                }
                .disabled(isDoing)
                .opacity(isDoing ? 0.8 : 1)
                
                if !isDoing {
                    Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(isEnabled ? .green : .red)
                        .font(.title2)
                        .animation(.spring(), value: isEnabled)
                }else{
                    ProgressView()
                        .tint(.white)
                }
                
                
            }
            .onAppear{
                if currentSet == 2556{
                    withAnimation{
                        checkedPro = true
                    }
                }else if currentSet == 2796{
                    withAnimation{
                        checkedProMax = true
                    }
                }

                switch UIDevice().machineName {
                case "iPhone11,8":
                    shouldRedBarFix = true
                    self.fetchRedBarValues()
                    break
                case "iPhone12,1":
                    shouldRedBarFix = true
                    self.fetchRedBarValues()
                    break
                default:
                    break
                }

            }
        }
        .tint(.white)
        .alert(isPresented: $shouldAlertDeviceSubTypeError) {
                        Alert(title: Text("Error"), message: Text("There was an error getting the deviceSubType, maybe your plist file is corrupted, please tap on Reset and reopen the app again.\nNote: Your device will respring."), dismissButton: .destructive(Text("Reset"),action: {
                            // restore plist
                            //killMobileGestalt()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                                respring()
                            }
                        }))
                    }
    }
    
    // MARK: functions

    func respring(){
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        view.alpha = 0

        UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first!.windows.first!.addSubview(view)
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            view.alpha = 1
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            spawnRoot("\(Bundle.main.bundlePath)/killall", ["-9", "backboardd"], nil, nil)
        })
    }

    func replacePlistData() {
        let url = URL(fileURLWithPath: dynamicPath)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any]
                var origDeviceType = getDefaultSubtype()
                if var cacheExtra = plist!["CacheExtra"] as? [String : Any], var oPeik = cacheExtra["oPeik/9e8lQWMszEjbPzng"] as? [String: Any], var artworkDeviceSubType = oPeik["ArtworkDeviceSubType"] as? Int {
                    if checkedPro {
                        artworkDeviceSubType = isEnabled ? 2556 : origDeviceType
                        currentSet = artworkDeviceSubType
                    }
                    if checkedProMax {
                        artworkDeviceSubType = isEnabled ? 2796 : origDeviceType
                        currentSet = artworkDeviceSubType
                    }
                    oPeik["ArtworkDeviceSubType"] = artworkDeviceSubType
                    cacheExtra["oPeik/9e8lQWMszEjbPzng"] = oPeik
                    plist!["CacheExtra"] = cacheExtra
                }

                // Save plist
                let plistData = try PropertyListSerialization.data(fromPropertyList: plist!, format: .xml, options: 0)
                try plistData.write(to: url)

                respring()
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
    }
    
    func setResolution() {
        do {
            let tmpPlistURL = URL(fileURLWithPath: "/var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist")

            if FileManager.default.fileExists(atPath: tmpPlistURL.path) {
                try? FileManager.default.removeItem(at: tmpPlistURL)
            } else {
                try createPlist(at: tmpPlistURL)
            }

            let aliasURL = URL(fileURLWithPath: "/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist")
            try? FileManager.default.removeItem(at: aliasURL)

            try FileManager.default.moveItem(at: tmpPlistURL, to: aliasURL)

            spawnRoot("\(Bundle.main.bundlePath)/killall", ["-9", "cfprefsd"], nil, nil)
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
        }
    }
    
    func fetchRedBarValues() {
        guard let url = URL(string: "https://raw.githubusercontent.com/matteozappia/DynamicCowTS/main/RedBarFixValues.json") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let redBarValues = try JSONDecoder().decode(RedBarValues.self, from: data)
                DispatchQueue.main.async {
                    self.redBarValues = redBarValues
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    
    func createPlist(at url: URL) throws {
        let canvasHeight: Int
        let canvasWidth: Int
        
        if isEnabled {
            canvasHeight = 1792
            canvasWidth = 828
        } else {
            canvasHeight = redBarValues?.height ?? 1971
            canvasWidth = redBarValues?.width ?? 911
        }
        
        let data: [String: Any] = [
            "canvas_height": canvasHeight,
            "canvas_width": canvasWidth,
        ]
        
        let nsData = NSDictionary(dictionary: data)
        nsData.write(toFile: url.path, atomically: true)
    }

    func getDefaultSubtype() -> Int {
           var deviceSubType: Int = originalDeviceSubType

           if deviceSubType == 0 {

               var canUseStandardMethod: [String] = ["10,3", "10,4", "10,6", "11,2", "11,4", "11,6", "11,8", "12,1", "12,3", "12,5", "13,1", "13,2", "13,3", "13,4", "14,4", "14,5", "14,2", "14,3", "14,7", "14,8", "15,2"]
               for (i, v) in canUseStandardMethod.enumerated() {
                   canUseStandardMethod[i] = "iPhone" + v
               }

               let deviceModel: String = UIDevice().machineName

               if canUseStandardMethod.contains(deviceModel) {
                   // can use device bounds
                   deviceSubType = Int(UIScreen.main.nativeBounds.height)
               } else {//else if specialCases[deviceModel] != nil {
                   //deviceSubType = specialCases[deviceModel]!
                   let url: URL? = URL(string: "https://raw.githubusercontent.com/matteozappia/DynamicCowTS/main/DefaultSubTypes.json")
                   if url != nil {
                       // get the data of the file
                       let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                           guard let data = data else {
                               print("No data to decode")
                               return
                           }
                           guard let subtypeData = try? JSONSerialization.jsonObject(with: data, options: []) else {
                               print("Couldn't decode json data")
                               return
                           }

                           // check if all the files exist
                           if  let subtypeData = subtypeData as? Dictionary<String, AnyObject>, let deviceTypes = subtypeData["Default_SubTypes"] as? [String: Int] {
                               if deviceTypes[deviceModel] != nil {
                                   // successfully found subtype
                                   deviceSubType = deviceTypes[deviceModel] ?? -1
                               }
                           }
                       }
                       task.resume()
                   }
               }

               // set the subtype
               if deviceSubType == 0 {
                   // get the current subtype
                   do {
                       let url = URL(fileURLWithPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
                       let data = try Data(contentsOf: url)

                       var plist = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]
                       let origDeviceTypeURL = URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ArtworkDeviceSubTypeBackup")

                       if !FileManager.default.fileExists(atPath: origDeviceTypeURL.path) {
                           let currentType = ((plist["CacheExtra"] as? [String: Any] ?? [:])["oPeik/9e8lQWMszEjbPzng"] as? [String: Any] ?? [:])["ArtworkDeviceSubType"] as! Int
                           deviceSubType = currentType
                           let backupData = String(currentType).data(using: .utf8)!
                           try backupData.write(to: origDeviceTypeURL)
                       }
                   } catch {
                       print(error.localizedDescription)
                   }
               }

               if deviceSubType == 0 {
                   withAnimation{
                       shouldAlertDeviceSubTypeError = true
                   }
               }
               originalDeviceSubType = deviceSubType
           }
           return deviceSubType
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
