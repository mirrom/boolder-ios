//
//  ProblemListView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemListView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedProblem: ProblemAnnotation
    @Binding var presentProblemDetails: Bool
    
    var body: some View {
        List {
            ForEach(Array(self.dataStore.groupedAnnotations.keys.sorted()), id: \.self) { grade in
                // FIXME: simplify the code by using a tableview footer when/if it becomes possible
                // NB: we want a footer view (or bottom inset?) to be able to show the FabFilters with no background when user scrolls to the bottom of the list
                Section(
                    header: Text("Niveau \(grade)").font(.title).bold().foregroundColor(Color(.label)).padding(.top, (grade == self.dataStore.groupedAnnotations.keys.sorted().first) ? 32 : 0),
                    footer: Rectangle().fill(Color.clear).frame(width: 1, height: (grade == self.dataStore.groupedAnnotations.keys.sorted().last) ? 120 : 0, alignment: .center)
                    ) {
                    ForEach(self.dataStore.groupedAnnotations[grade]!, id: \.self) { (problem: ProblemAnnotation) in
                        
//                        NavigationLink(destination: Text("\(problem.name ?? "")")) {
                        Button(action: {
                            self.selectedProblem = problem
                            self.presentProblemDetails = true
                        }) {
                            HStack {
                                Text(problem.displayLabel)
                                    .font(.headline)
                                    .foregroundColor(Color(problem.displayColor()))
                                    .frame(minWidth: 30, alignment: .leading)
                                Text(problem.name ?? "Sans nom")
                                    .foregroundColor(problem.name != nil ? Color(.label) : Color.gray)
                                Spacer()
                                Text(problem.grade?.string ?? "")
                            }
                        }
                        .foregroundColor(Color(.label))
//                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct ProblemListView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            ProblemListView(selectedProblem: .constant(ProblemAnnotation()), presentProblemDetails: .constant(false))
                .navigationBarTitle("Rocher Canon", displayMode: .inline)
        }
        .environmentObject(DataStore.shared)
    }
}
