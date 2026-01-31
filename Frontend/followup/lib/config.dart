// API 配置文件
class ApiConfig {
  // 本地开发
  static const String baseUrl = "http://localhost:8000";
  
  // 生产环境
  // static const String baseUrl = "https://your-app.railway.app";
  
  // API 超时设置
  static const Duration timeout = Duration(seconds: 30);
}
