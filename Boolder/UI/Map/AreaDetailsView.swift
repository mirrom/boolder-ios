//
//  AreaDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaDetailsView: View {
    @Environment(\.openURL) var openURL
    
    let area: Area
    @EnvironmentObject var appState: AppState
    let linkToMap: Bool
    
    @State private var poiRoutes = [PoiRoute]()
    
    var body: some View {
        ZStack {
            List {
                if area.tags.count > 0 {
                    if #available(iOS 16.0, *) {
                        Section {
                            FlowLayout(alignment: .leading) {
                                tags
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    else {
                        Section {
                            VStack(alignment: .leading) {
                                tags
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                if area.descriptionFr != nil || area.warningFr != nil {
                    Section {
                        if let descriptionFr = area.descriptionFr, let descriptionEn = area.descriptionEn {
                            VStack(alignment: .leading) {
                                Text(NSLocale.websiteLocale == "fr" ? descriptionFr : descriptionEn)
                            }
                        }
                        
                        if let warningFr = area.warningFr, let warningEn = area.warningEn {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocale.websiteLocale == "fr" ? warningFr : warningEn).foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                if poiRoutes.count > 0 {
                    ForEach(poiRoutes) { poiRoute in
                        if let poi = poiRoute.poi {
                            Section {
                                Button {
                                    if let url = URL(string: poi.googleUrl) {
                                        openURL(url)
                                    }
                                } label: {
                                    HStack {
                                        Text(poi.type.string)
                                        
                                        Spacer()
                                        
                                        if poi.type == .parking {
                                            Image(systemName: "p.square.fill")
                                                .foregroundColor(Color(UIColor(red: 0.16, green: 0.37, blue: 0.66, alpha: 1.00)))
                                                .font(.title2)
                                        }
                                        else if poi.type == .trainStation {
                                            Image(systemName: "tram.fill")
                                                .font(.body)
                                        }
                                        
                                        Text(poi.shortName)
                                    }
                                    .foregroundColor(.primary)
                                }
                                
                                HStack {
                                    Text(poiRoute.transport == .bike ? "area.bike_time" : "area.walking_time")
                                    
                                    Spacer()
                                    
                                    if poiRoute.transport == .bike {
                                        Image(systemName: "bicycle")
                                    }
                                    else {
                                        Image(systemName: "figure.walk")
                                    }
                                    
                                    Text("\(poiRoute.distanceInMinutes) min")
                                }
                            }
                        }
                    }
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
                        appState.selectedArea = area
                        appState.tab = .map
                    } label: {
                        Text("area.see_on_the_map")
                            .font(.body.weight(.semibold))
                            .padding(.vertical)
                    }
                    .buttonStyle(LargeButton())
                    .padding()
                }
            }
        }
        .onAppear {
            poiRoutes = area.poiRoutes
        }
        .navigationTitle(Text("area.infos"))
    }
    
    var tags: some View {
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
}

//struct AreaDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaDetailsView()
//    }
//}
