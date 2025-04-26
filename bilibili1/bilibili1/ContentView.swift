import SwiftUI

extension View {
    var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var hideTabBar = false
    var body: some View {
            ZStack(alignment: .bottom) {
                // 主内容区域
                Group {
                    switch selectedTab {
                    case 0:firstbili(hideTabBar: $hideTabBar)//传递绑定
                    case 1: subview()
                    case 2: uploadview()
                    case 3: buyview()
                    case 4: personview()
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 顶部雾面遮罩
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: safeAreaTop)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
                
                // 自定义TabBar
                if !hideTabBar{
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { index in
                            Button(action: {
                                selectedTab = index
                            }) {
                                VStack {
                                    if index == 2 {
                                        Image(systemName: "plus.square.fill")
                                            .foregroundStyle(
                                                AngularGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(#colorLiteral(red: 1, green: 0.4993596077, blue: 0.6586073637, alpha: 1)),
                                                        Color(#colorLiteral(red: 1, green: 0.3259485662, blue: 0.5486879945, alpha: 1))
                                                    ]),
                                                    center: .center,
                                                    angle: .degrees(180 + 45)
                                                )
                                            )
                                            .font(.largeTitle)
                                            .imageScale(.large)
                                            .padding(.top, 25)
                                    } else {
                                        Image(iconNames[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 20, height: 25)
                                            .padding(.top)
                                    }
                                    Text(tabTitles[index])
                                        .font(.caption)
                                }
                                .foregroundColor(selectedTab == index ?
                                                 Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)) : .gray)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(height: 49)
                    .background(Color.white.edgesIgnoringSafeArea(.bottom))
                }
                }

        }
        
    
    private let iconNames = ["首页", "动态", "", "会员购", "我的"]
    private let tabTitles = ["首页", "动态", "", "会员购", "我的"]
}

#Preview {
    ContentView()
}

