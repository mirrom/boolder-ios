//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import Charts

struct AreaView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let area: Area
    let mapState: MapState
    @Binding var appTab: ContentView.Tab
    let linkToMap: Bool
    
    @State private var circuits = [Circuit]()
    @State private var problemsCount = 0
    @State private var popularProblems = [Problem]()
    
    @State private var showChart = false
    
    struct Level: Identifiable {
        var name: String
        var count: Int
        var id = UUID()
    }

    @State private var data: [Level] = [
        .init(name: "1", count: 0),
        .init(name: "2", count: 0),
        .init(name: "3", count: 0),
        .init(name: "4", count: 0),
        .init(name: "5", count: 0),
        .init(name: "6", count: 0),
        .init(name: "7", count: 0),
        .init(name: "8", count: 0),
    ]
    
    var body: some View {
        ZStack {
            List {
                Section {
                    
                    NavigationLink {
                        List {
                            if area.tags.count > 0 {
                                if #available(iOS 16.0, *) {
                                    Section {
                                        FlowLayout(alignment: .leading) {
                                            ForEach(area.tags, id: \.self) { tag in
                                                Text(NSLocalizedString("area.tags.\(tag)", comment: ""))
                                                    .font(.callout)
                                                    .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                                                    .foregroundColor(Color.green)
                                                    .background(Color.systemBackground)
                                                    .cornerRadius(32)
                                                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.green, lineWidth: 1.0))
                                            }
                                        }
                                        .padding(.vertical, 4)
                                        //.background(Color.red)
                                    }
                                }
                            }
                        
                            Section {
                                if let descriptionFr = area.descriptionFr, let descriptionEn = area.descriptionEn {
                                    VStack(alignment: .leading) {
                                        Text(NSLocale.websiteLocale == "fr" ? descriptionFr : descriptionEn)
                                    }
                                }
                                
                                if let warningFr = area.warningFr, let warningEn = area.warningEn {
                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text("Important :").bold()
                                        Text(NSLocale.websiteLocale == "fr" ? warningFr : warningEn).foregroundColor(.orange)
                                    }
                                }
                            }
                            
                            if let url = area.parkingUrl, let name = area.parkingShortName, let distance = area.parkingDistance {
                                Section {
                                    HStack {
                                        Text("Parking")
                                        Spacer()
                                        Image(systemName: "p.square.fill")
                                            .foregroundColor(Color(UIColor(red: 0.16, green: 0.37, blue: 0.66, alpha: 1.00)))
                                            .font(.title2)
                                        Text(name)
                                        
                                        //                                Image(systemName: "arrow.up.forward.square").foregroundColor(Color.gray)
                                    }
                                    HStack {
                                        Text("Marche d'approche")
                                        Spacer()
                                        Text("\(Int(round(Double(distance/80)))) min")
                                    }
                                }
                            }
                        }
                        .navigationTitle(Text("Infos secteur"))
                    } label: {
                        HStack {
                            Text("Infos secteur")
                            Spacer()
                            
                            if let tagg = area.tags.first {
                                Text(NSLocalizedString("area.tags.\(tagg)", comment: ""))
                                    .lineLimit(1)
                                    .font(.callout)
                                    .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                                    .foregroundColor(Color.green)
                                    .background(Color.systemBackground)
                                    .cornerRadius(32)
                                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.green, lineWidth: 1.0))
                            }
                            
                            if area.tags.count > 1 {
                                Text("+\(area.tags.count-1)")
                                    .font(.callout)
                                    .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 8))
                                    .foregroundColor(Color.green)
                                    .background(Color.systemBackground)
                                    .cornerRadius(32)
                                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.green, lineWidth: 1.0))
                            }
                            
//                            if area.warningEn != nil {
//                                Image(systemName: "exclamationmark.circle")
//                                    .foregroundColor(.orange)
//                                    .font(.title3)
//                            }
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        AreaProblemsView(area: area, mapState: mapState, appTab: $appTab)
                    } label: {
                        HStack {
                            Text("Voies")
                            Spacer()
                            Text("\(problemsCount)")
                        }
                    }
                    
                    VStack {
                        Button {
                            showChart.toggle()
                        } label: {
                            HStack {
                                Text("Niveaux")
                                    .foregroundColor(.primary)
//                                Image(systemName: "chevron.down")
//                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                HStack(spacing: 2) {
                                    ForEach(area.levelsCount) { level in
                                        Text(String(level.name))
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.systemBackground)
                                            .background(level.count >= 20 ? Color.levelGreen : Color.gray.opacity(0.5))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }

                        if showChart {
                            if #available(iOS 16.0, *) {
                                Chart {
                                    ForEach(data) { shape in
                                        BarMark(
                                            x: .value("Level", shape.name),
                                            y: .value("Problems", shape.count)
                                        )
                                    }
                                }
                                .chartYScale(domain: 0...150)
                                .foregroundColor(.levelGreen)
                                .frame(height: 150)
//                                .padding(.horizontal)
                                .padding(.vertical)
                                .clipShape(Rectangle())
                            }
                        }
                    }
                }
                
                if(circuits.count > 0) {
                    Section {
                        ForEach(circuits) { circuit in
                            NavigationLink {
                                CircuitView(area: area, circuit: circuit, mapState: mapState, appTab: $appTab)
                            } label: {
                                HStack {
                                    CircleView(number: "", color: circuit.color.uicolor, height: 20)
                                    Text(circuit.color.longName)
                                    Spacer()
                                    if(circuit.beginnerFriendly) {
                                        Image(systemName: "face.smiling")
                                            .foregroundColor(.green)
                                            .font(.title3)
                                    }
                                    if(circuit.dangerous) {
                                        Image(systemName: "exclamationmark.circle")
                                            .foregroundColor(.orange)
                                            .font(.title3)
                                    }
                                    Text(circuit.averageGrade.string)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                if(popularProblems.count > 0) {
                    
                    Section(header:
                                //                        HStack {
                            //                Image(systemName: "heart.fill").foregroundColor(.pink)
                            Text("Populaires")
                            //            }
                    ) {
                        
                        ForEach(popularProblems) { problem in
                            Button {
                                //                        presentationMode.wrappedValue.dismiss()
                                mapState.presentAreaView = false
                                appTab = .map
                                mapState.selectAndPresentAndCenterOnProblem(problem)
                            } label: {
                                HStack {
                                    ProblemCircleView(problem: problem)
                                    Text(problem.nameWithFallback)
                                    Spacer()
                                    //                                if(problem.featured) {
                                    //                                    Image(systemName: "heart.fill").foregroundColor(.pink)
                                    //                                }
                                    Text(problem.grade.string)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        
                    }
                    
                    //                Section {
                    //                    NavigationLink {
                    //                        AreaProblemsView(viewModel: viewModel, appTab: $appTab)
                    //                    } label: {
                    //                        HStack {
                    //                            Text("Toutes les voies")
                    //                            Spacer()
                    //                            Text("\(viewModel.problemsCount)")
                    //                        }
                    //                    }
                    //                }
                }
                
                if(linkToMap) {
                    // leave room for sticky footer
                    Section(header: Text("")) {
                        EmptyView()
                    }
                    .padding(.bottom, 24)
                }
                
                
            }
            
            if(linkToMap) {
                VStack {
                    Spacer()
                    
                    Button {
                        mapState.selectArea(area)
                        mapState.centerOnArea(area)
                        appTab = .map
                    } label: {
                        Text("Voir sur la carte")
                            .font(.body.weight(.semibold))
                            .padding(.vertical)
                    }
                    .buttonStyle(LargeButton())
                    .padding()
                }
            }

        }
        .onAppear {
            circuits = area.circuits
            problemsCount = area.problemsCount
            popularProblems = area.popularProblems
            
            data = area.levelsCount
        }
        .navigationTitle(area.name)
        .navigationBarTitleDisplayMode(.inline)
        .modify {
            if(linkToMap) {
                $0
            }
            else {
                $0.navigationBarItems(
                    leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Fermer")
                            .padding(.vertical)
                            .font(.body)
                    }
                )
            }
        }
        
    }
    
}

//struct AreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaView(viewModel: AreaViewModel(areaId: 1))
//    }
//}
