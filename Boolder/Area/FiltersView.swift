//
//  FiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FiltersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: DataStore
    
    @State private var presentGradeFilter = false
    
    let userVisibleSteepnessTypes: [Steepness.SteepnessType] = [.wall, .slab, .overhang, .traverse]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: GradeFilterView(), isActive: $presentGradeFilter) {
                        HStack {
                            Text("Niveaux")
                            Spacer()
                            Text(labelForCategories(dataStore.filters.gradeCategories))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
                Section {
                    ForEach(userVisibleSteepnessTypes, id: \.self) { steepness in
                        
                        Button(action: {
                            self.steepnessTapped(steepness)
                        }) {
                            HStack {
                                Image(Steepness(steepness).imageName)
                                    .foregroundColor(Color(.label))
                                    .frame(minWidth: 20)
                                Text(Steepness(steepness).name)
                                    .foregroundColor(Color(.label))
                                Spacer()
                                
                                if self.dataStore.filters.steepness.contains(steepness) {
                                    Image(systemName: "checkmark").font(Font.body.weight(.bold))
                                }
                            }
                        }
                    }
                }
                
                Section {
                    HStack {
                        Toggle(isOn: $dataStore.filters.photoPresent) {
                            Text("Avec photo")
                        }
                    }
                }
            }
            .navigationBarTitle("Filtres", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Réinitialiser") {
                    self.dataStore.filters = Filters()
                    self.presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK").bold()
                }
            )
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
        }
    }
    
    private func steepnessTapped(_ steepness: Steepness.SteepnessType) {
        // toggle value for this steepness
        if self.dataStore.filters.steepness.contains(steepness) {
            self.dataStore.filters.steepness.remove(steepness)
        }
        else {
            self.dataStore.filters.steepness.insert(steepness)
        }
        
        // auto add/remove some values for user friendliness
        
        if self.dataStore.filters.steepness.isSuperset(of: Set(userVisibleSteepnessTypes)) {
            self.dataStore.filters.steepness.formUnion([.other, .roof])
        }
        else {
            self.dataStore.filters.steepness.subtract([.other, .roof])
            
            if self.dataStore.filters.steepness.contains(.overhang) {
                self.dataStore.filters.steepness.insert(.roof)
            }
        }
    }
    
    private func labelForCategories(_ categories: Set<Int>) -> String {
        let categories = Array(categories).sorted()
        
        if categories.isEmpty {
            return "Tous"
        }
        else {
            if categories.count == 1 {
                return String(categories.first!)
            }
            else if consecutiveNumbers(categories) {
                return "\(categories.min()!) à \(categories.max()!)"
            }
            else
            {
                return categories.sorted().map{String($0)}.joined(separator: ",")
            }
        }
    }
    
    private func consecutiveNumbers(_ categories: [Int]) -> Bool {
        if categories.count < 2 { return false }
        
        for i in 0..<categories.count {
            if i > 0 {
                if categories[i] != (categories[i-1] + 1) { return false }
            }
        }
        return true
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FiltersView()
        }
    }
}

struct GradeFilterView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        List {
            Section {
                ForEach(Filters.allGradeCategories, id: \.self) { category in
                    Button(action: {
                        if self.dataStore.filters.gradeCategories.contains(category) {
                            self.dataStore.filters.gradeCategories.remove(category)
                        }
                        else {
                            self.dataStore.filters.gradeCategories.insert(category)
                        }
                    }) {
                        HStack {
                            Text("Niveau \(category)").foregroundColor(Color(.label))
                            Spacer()
                            if self.dataStore.filters.gradeCategories.contains(category) {
                                Image(systemName: "checkmark").font(Font.body.weight(.bold))
                            }
                        }
                    }
                }
            }
            
            Section {
                Button(action: {
                    self.dataStore.filters.gradeCategories = Set<Int>()
                }) {
                    Text("Tous les niveaux").foregroundColor(Color(.label))
                }
            }
        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Niveaux")
    }
}
