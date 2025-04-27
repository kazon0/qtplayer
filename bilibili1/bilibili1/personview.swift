//
//  personview.swift
//  bilibili1
//
//  Created by 郑晗希 on 2025/4/6.
//

import SwiftUI

struct personview: View {
    @State  var columns:[GridItem]=[
        GridItem(.flexible(), spacing: nil, alignment: nil)
    ]
    let items = [
        "收藏栏",
        "创作中心",
        "推荐服务",
        "更多服务"
    ]
    var body: some View {
        ZStack{
            
            ScrollView(.vertical,showsIndicators: false){
                VStack{
                    LazyVGrid(columns: columns, pinnedViews: [.sectionHeaders]){
                        Section(header: headView()){
                            ForEach(0..<items.count,id: \.self){index in
                                Image(items[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width)//屏幕宽度
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    personview()
}

struct headView: View {
    var body: some View {
        Image("selfmessage")
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width)//屏幕宽度
            .cornerRadius(15)
    }

}


