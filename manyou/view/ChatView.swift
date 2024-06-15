import SwiftUI
import EventSource

struct MessageData: Codable {
    let content: String
    
}

class SSEClient: ObservableObject {
    @Published var messages: [String] = []
    private var eventSourceDataTask: EventSource.DataTask?
    var curIndex:Int = -1;
    var msg:String = "";
    func connect(url: URL, headers: [String: String], queryParams: [String: String?]) {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        curIndex+=1
        self.messages.append("")
        let nonOptionalQueryParams = queryParams.compactMapValues { $0 }
        urlComponents?.queryItems = nonOptionalQueryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalURL = urlComponents?.url else {
            print("Failed to construct URL with query parameters")
            return
        }
        
        var requestHeaders = ["Accept": "text/event-stream"]
        for (key, value) in headers {
            requestHeaders[key] = value
        }
        
        var urlRequest = URLRequest(url: finalURL)
        for (key, value) in requestHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        let eventSource = EventSource()
        eventSourceDataTask = eventSource.dataTask(for: urlRequest)
        
        Task {
            for await event in eventSourceDataTask!.events() {
                switch event {
                case .open:
                    print("Connection opened")
                case .closed:
                    print("Connection closed")
                case .error(let error):
                    print("Connection failed with error: \(error)")
                case .message(let serverMessage):
                    print("Connection serverMessageh: \(serverMessage)")
                    handleEvent(serverMessage: serverMessage)
                    
                }
            }
        }
    }
    private func handleEvent( serverMessage:ServerMessage) {
        if let event = serverMessage.event {
            switch event {
            case "msg":
                handleCustomEvent(dataString: serverMessage.data)
            default:
                handleDefaultEvent(dataString: serverMessage.data)
            }
        } else {
            handleDefaultEvent(dataString: serverMessage.data)
        }
    }
    
    private func handleCustomEvent(dataString: String?) {
        guard let dataString = dataString else {
            print("Data string is nil")
            return
        }
        
        guard let jsonData = dataString.data(using: .utf8) else {
            print("Failed to convert string to data: \(dataString)")
            return
        }
        
        do {
            let messageData = try JSONDecoder().decode(MessageData.self, from: jsonData)
            DispatchQueue.main.async {
                self.msg += messageData.content
                self.messages[self.curIndex] = self.msg // 更新占位符数据
                
            }
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
    
    private func handleDefaultEvent(dataString: String?) {
        guard let dataString = dataString else {
            print("Data string is nil")
            return
        }
        
        DispatchQueue.main.async {
            self.messages.append(dataString)
        }
    }
    
    func disconnect() {
        eventSourceDataTask?.cancel()
        eventSourceDataTask = nil
    }
}




struct SSEChatView: View {
    @StateObject private var sseClient = SSEClient()
    @State private var newMessage: String = ""
    @EnvironmentObject var userManager: UserManager
   
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(sseClient.messages.indices, id: \.self) { index in
                        Text(sseClient.messages[index])
                            .padding()
                            .foregroundColor(.white) // 设置字体颜色
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity) // 使 ScrollView 充满宽度
                .padding()
            }
          
            
            HStack {
                TextField("Enter your message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                
                Button(action: {
                    sseClient.curIndex+=1
                    sseClient.messages.append(newMessage)
                    // 发送实际消息到服务器
                    if let url = URL(string: "http://39.101.191.170:8080/manyou/sendMsg2") {
                        let tk=userManager.token!
                        let headers  = ["token": tk]
                        let queryParams = ["msg": newMessage, "fid": "1"]
                        sseClient.connect(url: url, headers: headers, queryParams: queryParams)
                    }
                    newMessage = ""
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        } .background(Color( UIColor(red: 43/255.0, green: 43/255.0, blue: 59/255.0, alpha: 1.0)))

        .navigationBarTitle("manyou", displayMode: .inline)
            .navigationBarItems(trailing: HStack {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(.green)
                Text("新会话")
                    .foregroundColor(.white)
            })
            .onAppear {
                setupNavigationBarAppearance()
            }
            .onDisappear {
                sseClient.disconnect()
            }
    }
    private func setupNavigationBarAppearance() {
            // 自定义导航栏外观
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
        let customColor = UIColor(red: 59/255.0, green: 59/255.0, blue: 75/255.0, alpha: 1.0)

        appearance.backgroundColor = customColor

            // 设置返回按钮的外观
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear] // 隐藏返回按钮的文字
        // 设置标题颜色
               appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
               appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            // 将外观设置应用于导航栏
            appearance.backButtonAppearance = backButtonAppearance
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().tintColor = .white // 设置返回按钮颜色

            // 隐藏默认标题文本
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.clear]
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.clear]
        }
    
}


struct SSEChatView_Previews: PreviewProvider {
    static var previews: some View {
        SSEChatView()
    }
}
