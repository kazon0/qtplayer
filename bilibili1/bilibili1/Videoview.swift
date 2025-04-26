//
//  firstbili.swift
//  bilibili1
//
//  Created by 郑晗希 on 2025/3/26.
//



import SwiftUI


struct VideoPlayerView: View {
    //用环境变量控制导航
    @Environment(\.dismiss) private var dismiss
    @Binding var hideTabBar: Bool
    let choosetitle = ["简介", "评论"]
    @State var selectionTitle :String = "简介"
    // 定义单列布局
    let columns = [GridItem(.flexible())]  // 只有一列，宽度灵活填充
    @State private var offset = CGSize.zero
    @State var guesture :String = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .leading, spacing: 0) {
                // 视频封面/播放区域
                if guesture != "up"{
                ZStack(alignment: .bottom) {
                    VStack(alignment: .leading,spacing: 0){
                        ZStack(alignment: .topLeading){
                            Image("roll2")
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width)
                                .clipped()
                            // 返回按钮
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color(#colorLiteral(red: 0.7345525622, green: 0.7345526218, blue: 0.7345525622, alpha: 1)))
                            }
                            .padding()
                    
                        }
                        
                        // 播放控制条
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            
                            // 进度条（使用 ZStack 叠加背景和进度）
                            ZStack(alignment: .leading) {
                                // 背景：深灰色渐变
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(#colorLiteral(red: 0.7772451043, green: 0.7772451043, blue: 0.7772451043, alpha: 0.8470588326)),
                                                       Color(#colorLiteral(red: 0.8718039989, green: 0.8718039989, blue: 0.8718039989, alpha: 0.8470588326))],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 4) // 高度与 B站一致
                                
                                // 进度指示：粉色（B站主题色）
                                Capsule()
                                    .fill(Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1))) // B站粉
                                    .frame(width: UIScreen.main.bounds.width * 0.3, height: 4) // 30% 进度示例
                            }
                            .frame(height: 4) // 控制条总高度
                            
                            Text("1:24/03:29")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                            
                            Spacer()
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                    }
                    
                }
            }
           
                    LazyVGrid(columns: columns, pinnedViews: [.sectionHeaders]) {
                        Section(header : headerView) {
                            if selectionTitle == "评论"{
                                TotalCommentView()
                            }
                            else if selectionTitle == "简介"{
                                SimpleMesView()
                            }
                        }
                    }
                    

                }
            }
        .offset(offset)
        .simultaneousGesture(//避免被scrollview盖过
            DragGesture()
                .onChanged { gesture in
                    self.offset = CGSize(width: 0, height: gesture.translation.height)
                }
                .onEnded { gesture in
                    let swipeThreshold: CGFloat = 100
                    if gesture.translation.height > swipeThreshold {
                        // 向下滑动
                        print("向下滑动")
                        guesture="down"
                    } else if gesture.translation.height < -swipeThreshold {
                        // 向上滑动
                        print("向上滑动")
                        guesture="up"
                    }
                    self.offset = .zero
                }
        )
        .onAppear {
             hideTabBar = true // 进入时隐藏标签栏
         }
        .navigationBarHidden(true)
    }
    
    var headerView: some View {
        //导航栏
        VStack(spacing: 0){
            if guesture=="up"{
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Text("继续播放")
                        .font(.title3)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))// 旋转90度
                        .foregroundColor(.white)
                        .padding()
                }
                .padding(.vertical,10)
                .background(Color.black.opacity(0.8))
                .transition(.move(edge: .top))
                .zIndex(1)
            }
            HStack(spacing: nil) {
                ForEach(choosetitle, id: \.self){ title in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)){selectionTitle = title}
                    }) {
                        if selectionTitle == title{
                            VStack(spacing:0){
                                Text(title)
                                    .font(.system(.headline, weight: .light))
                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 0.3539066911, blue: 0.6795577407, alpha: 1)))
                                    .padding(.vertical,12)
                                    .overlay(//单独处理下划线动画
                                        Group {
                                if selectionTitle == title {
                                    Divider()
                                        .frame(width: 40, height: 2)
                                        .background(Color.pink)
                                        .transition(.opacity) //只使用淡入淡出
                                }},alignment: .bottom)}}
                        else{
                                Text(title)
                                    .font(.system(.headline, weight: .light))
                                    .foregroundColor(.gray)
            
                            
                        }
                    }
                    .padding(.horizontal,nil)
                 
                }
                Spacer()
                SplitCapsuleButton(
                    leftAction: {
                        print("Left tapped")
                        
                    },
                    rightAction: { print("Right tapped") },
                    leftText: "Left",
                    rightText: "Right"
                )
                
            }
            .padding(.horizontal,nil)
            .padding(.vertical,7)
            Divider()
                .offset(y: -8) // 向上移动8pt，与按钮文字padding一致
        }
        .background(Color.white)
    }
}

struct ConnectVideoView: View {
    let username: String
    let image: String
    let title: String
    let count1: String
    let count2: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack() {
                Image(image)
                    .resizable()
                    .frame(width: 150, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(alignment: .leading, spacing: 8) {
                
                    Text(title)
                        .font(.system(.callout))
                        .foregroundColor(.black)
                    Spacer()
                    HStack(spacing: 8) {
                        Text(username)
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(Color(#colorLiteral(red: 0.5174005032, green: 0.5174005032, blue: 0.5174005032, alpha: 1)))
                    }
                    HStack{
                        Text(count1)
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(Color(#colorLiteral(red: 0.5174005032, green: 0.5174005032, blue: 0.5174005032, alpha: 1)))
                        Text(count2)
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(Color(#colorLiteral(red: 0.5174005032, green: 0.5174005032, blue: 0.5174005032, alpha: 1)))
                        Spacer()
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))// 旋转90度
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                        }
                    }
               
                    }
                    .padding(.leading,3)
                }
            }

        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        Divider()
    }
}

struct CommentView: View {
    let username: String
    let avatar: String
    let content: String
    let time: String
    let likes: String
    @State var isLiked: Bool
    @State var isunLiked: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(avatar)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(username)
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(Color(#colorLiteral(red: 0.5174005032, green: 0.5174005032, blue: 0.5174005032, alpha: 1)))
                    }
                    Text(content)
                        .font(.system(size: 14))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 16) {
                Button(action: {
                    isLiked.toggle()
                    isunLiked=false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(isLiked ? Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)) : .gray)
                            .font(.system(size: 12))
                        Text(likes)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Button(action: {
                    isunLiked.toggle()
                    isLiked=false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isunLiked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .foregroundColor(isunLiked ? Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)) : .gray)
                            .font(.system(size: 12))
                    }
                }
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "text.bubble")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        
                        Text("回复")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {

                        Text(time)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))// 旋转90度
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
            }
            .padding(.leading, 40)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        Divider()
    }
}

struct SplitCapsuleButton: View {
    let leftAction: () -> Void
    let rightAction: () -> Void
    let leftText: String
    let rightText: String
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: leftAction) {
                Text("点我发弹幕")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(#colorLiteral(red: 0.7345525622, green: 0.7345526218, blue: 0.7345525622, alpha: 1)))
                    .padding(.horizontal, 16)
                    .padding(.vertical, nil)
                    .background(Color(#colorLiteral(red: 0.9447798133, green: 0.9447798133, blue: 0.9447798133, alpha: 1)))
                    
            }
            
            Divider()
            
            Button(action: rightAction) {
                Text("弹")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, nil)
                    .background(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 35)
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct TotalCommentView: View {
    @State private var showComments = true
    @State private var commentText = ""
    let choosetype = ["热门评论","最新评论"]
    @State var selectionType :String = "热门评论"
    var body: some View {
        //评论区标题
        HStack {
            Text(selectionType)
                .font(.system(.caption, weight: .light))
                .foregroundColor(Color(#colorLiteral(red: 0.5174005032, green: 0.5174005032, blue: 0.5174005032, alpha: 1)))
            Spacer()
            Button(action: {
                if selectionType == "热门评论"{
                    selectionType = "最新评论"
                }
                else{
                    selectionType = "热门评论"
                }
            }) {
                if selectionType == "热门评论"{
                    HStack(spacing: 2){
                        Image(systemName:"list.bullet")
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(.gray)
                        Text("按热度")
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(Color(#colorLiteral(red: 0.5174005032, green: 0.5174005032, blue: 0.5174005032, alpha: 1)))
                    }
                }
                else{
                    HStack(spacing: 2){
                        Image(systemName:"list.bullet")
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(.gray)
                        Text("按时间")
                            .font(.system(.caption, weight: .light))
                            .foregroundColor(Color(#colorLiteral(red: 0.5174005032, green: 0.5174005032, blue: 0.5174005032, alpha: 1)))
                    }
                }
                
            }
        }
        .padding(.horizontal,nil)
        .padding(.vertical,6)
        .padding(.bottom,10)
        
        if showComments {
            // 热门评论
            CommentView(username: "搜索引擎在冬天", avatar: "头像", content: "假如我有四亿美金，我天天都很平静。", time: "3小时前", likes: "25", isLiked: false,isunLiked: false)
            CommentView(username: "天蓝蓝没吃药", avatar: "头像", content: "天天笑哈基米哈气，搞半天自己就是应急的哈基米", time: "5小时前", likes: "282", isLiked: false,isunLiked: false)
            CommentView(username: "怀旧党", avatar: "头像", content: "怎么说 咋搞 说的就是我", time: "昨天", likes: "2", isLiked: false,isunLiked: false)
            CommentView(username: "怀旧党", avatar: "头像", content: "怎么说 咋搞 说的就是我", time: "昨天", likes: "2", isLiked: false,isunLiked: false)
            CommentView(username: "怀旧党", avatar: "头像", content: "怎么说 咋搞 说的就是我", time: "昨天", likes: "2", isLiked: false,isunLiked: false)
            CommentView(username: "怀旧党", avatar: "头像", content: "怎么说 咋搞 说的就是我", time: "昨天", likes: "2", isLiked: false,isunLiked: false)
            CommentView(username: "怀旧党", avatar: "头像", content: "怎么说 咋搞 说的就是我", time: "昨天", likes: "2", isLiked: false,isunLiked: false)
            CommentView(username: "怀旧党", avatar: "头像", content: "怎么说 咋搞 说的就是我", time: "昨天", likes: "2", isLiked: false,isunLiked: false)
        }
    }
}
    
    struct SimpleMesView: View {
        @State private var isLiked = false
        @State private var isunLiked = false
        @State private var isCollected = false
        @State private var isCoined = false
        
        let videoTitle = "长期处于心理应激的人，一眼就能看穿"
        let upName = "远叔"
        let upFans = "12.6万粉丝"
        let videoDescription = "无"
        let viewsCount = "25.9万"
        let danmuCount = "799"
        let publishTime = "2025-03-24 11:37 17人正在看"
        var body: some View {
            // UP主信息区域
            HStack {
                Image("头像")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(upName)
                        .font(.system(size: 15, weight: .medium))
                    Text(upFans)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // 关注动作
                }) {
                    Text("+ 关注")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)))
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            // 视频信息区域
            VStack(alignment: .leading, spacing: 12) {
                Text(videoTitle)
                    .font(.system(size: 18, weight: .medium))
                    .lineLimit(2)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.rectangle")
                            .foregroundColor(.gray)
                        Text(viewsCount)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "text.bubble")
                            .foregroundColor(.gray)
                        Text(danmuCount)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text(publishTime)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .font(.system(size: 12))
                Spacer()
                
                // 互动按钮区域
                HStack(spacing: 50) {
                    VStack(spacing: 4) {
                        Button(action: {
                            isLiked.toggle()
                            isunLiked=false
                        }) {
                            Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .font(.system(size: 22))
                                .foregroundColor(isLiked ? Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)) : .gray)
                        }
                        Text("8879")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Button(action: {
                            isunLiked.toggle()
                            isLiked=false
                        }) {
                            Image(systemName: isunLiked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .font(.system(size: 22))
                                .foregroundColor(isunLiked ? Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)) : .gray)
                        }
                        Text("不喜欢")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Button(action: {
                            isCoined.toggle()
                        }) {
                            Image(systemName: isCoined ? "dollarsign.circle.fill" : "dollarsign.circle")
                                .font(.system(size: 22))
                                .foregroundColor(isCoined ? Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)) : .gray)
                        }
                        Text("1793")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 4) {
                        Button(action: {
                            isCollected.toggle()
                        }) {
                            Image(systemName: isCollected ? "star.fill" : "star")
                                .font(.system(size: 22))
                                .foregroundColor(isCollected ? Color(#colorLiteral(red: 1, green: 0.35, blue: 0.68, alpha: 1)) : .gray)
                        }
                        Text("1.1万")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    
                    VStack(spacing: 4) {
                        Button(action: {
                            // 分享动作
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                        }
                        Text("1579")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Divider()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            ConnectVideoView(username: "怀旧党", image: "roll1", title: "怎么说 咋搞 说的就是我", count1: "11.1万",count2: "55")
            ConnectVideoView(username: "怀旧党", image: "roll1", title: "怎么说 咋搞 说的就是我", count1: "11.1万",count2: "55")
            ConnectVideoView(username: "怀旧党", image: "roll1", title: "怎么说 咋搞 说的就是我", count1: "11.1万",count2: "55")
            ConnectVideoView(username: "怀旧党", image: "roll1", title: "怎么说 咋搞 说的就是我", count1: "11.1万",count2: "55")
            ConnectVideoView(username: "怀旧党", image: "roll1", title: "怎么说 咋搞 说的就是我", count1: "11.1万",count2: "55")
            ConnectVideoView(username: "怀旧党", image: "roll1", title: "怎么说 咋搞 说的就是我", count1: "11.1万",count2: "55")
        }
    }

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建一个本地状态用于预览
        struct PreviewWrapper: View {
            @State private var hideTabBar = false
            
            var body: some View {
                VideoPlayerView(hideTabBar: $hideTabBar)
            }
        }
        
        return PreviewWrapper()
    }
}
