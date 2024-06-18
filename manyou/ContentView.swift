import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        if (isLoggedIn) {
            MainView()
        } else {
            VStack {
                Text("登录")
                    .font(.largeTitle)
                    .padding(.bottom, 40)
                
                TextField("用户名", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                SecureField("密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                
                Button(action: {
                    login()
                }) {
                    Text("登录")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("登录结果"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
                }
                
            }
        }
    
}

func login() {
    guard let url = URL(string: "http://39.101.191.170:8080/manyou/login") else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: String] = ["phone": username, "yzm": password]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        alertMessage = "请求数据格式错误"
        showingAlert = true
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                alertMessage = "请求失败: \(error.localizedDescription)"
                showingAlert = true
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                alertMessage = "无效的响应数据"
                showingAlert = true
            }
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                DispatchQueue.main.async {
                    print("响应数据: \(json)")
                    let tk=json["token"] as? String
                    let rk=json["refreshtoken"] as? String

                    UserManager.shared.token=tk
                    UserManager.shared.refresh_token=rk
                    isLoggedIn = true
                    
                }
            }
        } catch {
            DispatchQueue.main.async {
                alertMessage = "响应数据解析错误"
                showingAlert = true
            }
        }
    }.resume()
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

