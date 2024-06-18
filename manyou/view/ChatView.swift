import SwiftUI
import EventSource

struct MessageData: Codable {
    let content: String
        let msg: String
        
        enum CodingKeys: String, CodingKey {
            case content
            case msg
        }
        
        init(content: String, msg: String) {
            self.content = content
            self.msg = msg
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
            self.msg = try container.decodeIfPresent(String.self, forKey: .msg) ?? ""
        }
    
}
struct QA: Codable,Identifiable {
    let id: UUID = UUID()

    let question: String
    let name: String
    let description: String
}
struct MSGQA: Codable {
    let qaList: [QA]
    let messageList: [MessageData]
}
class SSEClient: ObservableObject {
    @Published var messages: [String] = []
    @Published var items: [QA] = [] // 新增的属性，用于存储从 API 获取的数据
    private var eventSourceDataTask: EventSource.DataTask?
    var curIndex:Int = -1;
    var content:String = "";
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
    func fetchItems() {
           guard let url = URL(string: "http://39.101.191.170:8080/manyou/getQA") else {    print("FfetchItemsno")
               return }
        print("FfetchItems")

        var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let tk=UserManager.shared.token!
                // 假设我们需要发送以下 JSON 数据
                let parameters: [String: Any] = [
                    "type": "1",
                    "token":tk
                ]
                
                // 将参数转换为 JSON 数据
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch {
                    print("Failed to serialize JSON: \(error)")
                    return
                }
        
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            // Print the JSON data as a string
                               if let jsonString = String(data: data, encoding: .utf8) {
                                   print("res Body: \(jsonString)")
                               }
                            let decodedItems = try JSONDecoder().decode(MSGQA.self, from: data)
                            DispatchQueue.main.async {
                                self.items = decodedItems.qaList
                            }
                        } catch {
                            print("Failed to decode items: \(error)")
                        }
                    } else if let error = error {
                        print("Failed to fetch items: \(error)")
                    }
                }
                
                task.resume()
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
                self.content += messageData.content
                self.messages[self.curIndex] = self.content // 更新占位符数据
                
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
    @State private var newMessage: String = ""
    @StateObject private var sseClient = SSEClient()
    var body: some View {
        VStack {
            // 新增的横向 ScrollView
                      ScrollView(.horizontal, showsIndicators: false) {
                          HStack(spacing: 10) {
                              ForEach(sseClient.items) { item in
                                  VStack {
                                    
                                      Text(item.name)
                                          .font(.caption)
                                          .padding(10)
                                          .background(Color.purple) // 设置背景颜色为紫色
                                        .cornerRadius(10) // 设置圆角
                                          .foregroundColor(.white) // 设置字体颜色为白色
                                  }
                                  
                              }
                          }
                          .padding(.horizontal)
                      }
                      .frame(height: 50)
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
                        let tk=UserManager.shared.token!
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
                sseClient.fetchItems()

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
