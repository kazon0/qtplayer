//
//  SimpleSearchView.swift
//  bilibili1
//
//  Created by 郑金坝 on 2025/4/18.
//

import SwiftUI


struct searchview: View {
    @Binding var hideTabBar: Bool
    @Environment(\.dismiss) private var dismiss
    var body: some View {
            VStack {
                HStack {
                    // 返回按钮
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                    }
                    SearchBarView()
                }
                Spacer()
                ScrollView(.vertical, showsIndicators: false) {
                    Image("searchview")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 600)
                }
            }
            .padding(.horizontal)
        .onAppear {
             hideTabBar = true // 进入时隐藏标签栏
         }
        .navigationBarHidden(true) // 隐藏导航栏
    }
}


struct SearchBarView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    // 自定义颜色扩展
    private struct Colors {
        static let lightGray = Color(red: 0.96, green: 0.96, blue: 0.96)
        static let textSecondary = Color.gray
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                TextField("搜索视频、UP主或BV号", text: $searchText) {
                    // 搜索提交动作
                    performSearch()
                }
                .textFieldStyle(.plain)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .submitLabel(.search)
                .padding(.vertical, 8)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(Colors.lightGray)
            .cornerRadius(8)
            .onTapGesture {
                isSearching = true
            }
            
        }
        .contentShape(Rectangle())
        .padding(.horizontal)
        .frame(height: 44)
    }
    
    private func performSearch() {
        print("执行搜索: \(searchText)")
        hideKeyboard()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct searchview_Previews: PreviewProvider {
    static var previews: some View {
        // 创建一个本地状态用于预览
        struct PreviewWrapper: View {
            @State private var hideTabBar = false
            
            var body: some View {
                searchview(hideTabBar: $hideTabBar)
            }
        }
        
        return PreviewWrapper()
    }
}
