//
//  firstbili.swift
//  bilibili1
//
//  Created by 郑晗希 on 2025/3/26.
//

import SwiftUI

struct firstbili: View {
    @State  var columns:[GridItem]=[
        GridItem(.flexible(), spacing: nil, alignment: nil)
    ]
    
    @State var columns2:[GridItem] = [
        GridItem(.flexible(), spacing: nil, alignment: nil),
        GridItem(.flexible(), spacing: nil, alignment: nil)
    ]
    @State private var showSearchView = false // 状态提升到这里
    @State private var showVideoView = false
    @Binding var hideTabBar: Bool
    var body: some View {
        NavigationStack { // 添加导航容器
            ZStack {
                Showscroll(
                    columns: $columns,
                    columns2: $columns2,
                    hideTabBar: $hideTabBar,
                    showSearchView: $showSearchView, showVideoView: $showVideoView
                )
            }
            .navigationBarHidden(true) // 隐藏主界面导航栏
            .padding(.horizontal)
            .navigationDestination(isPresented: $showSearchView) {
                searchview(hideTabBar: $hideTabBar)
                    .navigationBarBackButtonHidden(true) // 隐藏返回按钮
            }
            .navigationDestination(isPresented: $showVideoView){
                VideoPlayerView(hideTabBar: $hideTabBar)
                    .navigationBarBackButtonHidden(true) // 隐藏返回按钮
            }
            .onAppear {
                     hideTabBar = false // 确保返回首页时显示标签栏
                 }
        }
    }
}

#Preview {
    // 创建一个本地状态用于预览
    struct PreviewWrapper: View {
        @State private var hideTabBar = false
        
        var body: some View {
            firstbili(hideTabBar: $hideTabBar)
        }
    }
    
    return PreviewWrapper()
}



struct Showscroll: View {
    let choosetitle = ["直播", "推荐", "热门", "动画", "影视", "新征程"]
    let items = [
        "bv1",
        "bv2",
        "bv3",
        "bv4",
        "bv5"
    ]
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State var selectionTitle :String = "推荐"
    @Binding var columns: [GridItem]
    @Binding var columns2: [GridItem]
    @Binding var hideTabBar: Bool
    
    // 搜索相关状态
    @State private var searchText = ""
    @State private var isSearching = false
    @Binding var showSearchView: Bool // 接收绑定
    
    // 进入视频页面相关状态
    @State private var isVideoing = false
    @Binding var showVideoView: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            // 1. 用户头像部分（不受网格限制）
            HStack(spacing: nil){
                Button(action:{
                    
                }){
                    Image("头像")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(30)
                }
                Button(action:{
                    showSearchView=true
                    hideTabBar = true
                }){
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            //Text("搜索视频、UP主或BV号")
                            .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // 关键：移除按钮默认样式
                Button(action:{
                    
                }){
                    Image(systemName: "gamecontroller")
                        .frame(width: 40)
                        .foregroundStyle(.gray)
                }
                Button(action:{
                    
                }){
                    Image(systemName:"envelope")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, pinnedViews: [.sectionHeaders]) {
                Section(header : headerView) {
                    SimpleAutoScrollView()
                    //网格嵌套
                    LazyVGrid(columns: columns2, pinnedViews: []) {
                        ForEach(0..<items.count,id: \.self){index in
                            Button(action:{
                                showVideoView=true
                                hideTabBar = true // 点击视频时隐藏标签栏
                            }){
                                Image(items[index])
                                    .resizable()
                                    .frame(width: 180,height: 200)
                                    .cornerRadius(15)
                            }
                            
                        }
                        
                    }
                }
            }
            .background(Color(#colorLiteral(red: 0.8802281022, green: 0.8802281022, blue: 0.8802281022, alpha: 1)).opacity(0.3))
            
        }
    }
    
    // 横向滚动栏目（独立组件）
    struct SimpleAutoScrollView: View {
        let items = [
            "roll1",
            "roll2",
            "roll3"
        ]
        @State private var currentIndex = 0
        @State private var timer: Timer?
        
        var body: some View {
            VStack {
                // 1. 可滚动的页面
                TabView(selection: $currentIndex) {
                    ForEach(0..<items.count, id: \.self) { name in
                        Button(action :{
                            //
                        }){
                            Image(items[name])//循环遍历必须是数字才能实现滚动
                                .resizable()
                                    .scaledToFill()
                                    .frame(width: 350, height: 200)
                                    .cornerRadius(15)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 210)
            }
            .onAppear {startTimer()}
            .onDisappear {stopTimer()}
        }
        
        func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % items.count
                }
            }
        }
        
        func stopTimer() {
            timer?.invalidate()
        }
    }
    
    // 标题视图（保持不变）
    var headerView: some View {
       
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(choosetitle, id: \.self) { title in
                    Button(action: {
                        selectionTitle = title
                    }) {
                        if selectionTitle == title{
                            Text(title)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(#colorLiteral(red: 1, green: 0.3539066911, blue: 0.6795577407, alpha: 1)))
                                .underline()
                        }
                        else{
                            Text(title)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                  
                    }
                    .padding(15)
                }
            }
        }
        .background(Color.white)
    }
}
