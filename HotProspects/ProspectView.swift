//
//  ProspectView.swift
//  HotProspects
//
//  Created by Reza Enayati on 9/30/24.
//

import SwiftUI
import SwiftData
import CodeScanner
import UserNotifications

struct ProspectView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    
    @State private var showingScanner = false
    @State private var selectedProspects = Set<Prospect>()
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted"
        case .uncontacted:
            "Uncontaced"
        }
    }
    
    
    var body: some View {
        NavigationStack{
            List(prospects, selection: $selectedProspects) {prospect in
                VStack(alignment: .leading) {
                    Text(prospect.name)
                        .font(.headline)
                    Text(prospect.email)
                        .foregroundStyle(.secondary)
                }
                .tag(prospect)
                .swipeActions{
                    
                    Button("Delete", systemImage: "trash") {
                        modelContext.delete(prospect)
                    }
                    .tint(.red)
                    
                    if prospect.contacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                            prospect.contacted.toggle()
                        }
                        .tint(.blue)
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                            prospect.contacted.toggle()
                        }
                        .tint(.green)
                        
                        Button("Remind Me", systemImage: "bell") {
                            addNotification(for: prospect)
                        }
                        .tint(.orange)
                    }
                    
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        showingScanner = true
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                if selectedProspects.isEmpty == false {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete Selction", action: delete)
                    }
                }
            }
            .sheet(isPresented: $showingScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Reza Enayati\nr3zsoft@gmail.com",completion: handleScanResults)
            })
        }
    }
    
    init(filter: FilterType) {
        self.filter = filter
        
        if filter != .none {
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate{
                $0.contacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
    
    func handleScanResults(result: Result<ScanResult, ScanError>) {
        showingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            let newProspect = Prospect(name: details[0], email: details[1], contacted: false)
            modelContext.insert(newProspect)
        case .failure(let error):
            print("Error Adding Prospect: \(error.localizedDescription)")
        }
    }
    
    func delete(){
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.email
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization { success, error in
                    if success {
                        
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
         }
        
    }
}

#Preview {
    ProspectView(filter: .none)
        .modelContainer(for: Prospect.self)
}
