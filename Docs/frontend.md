# FollowUP 前端开发计划

> 技术栈：Flutter (iOS / Android / Web)

---

## 一、API 接口调用规范

### 1.1 基础配置

```dart
// config.dart
class ApiConfig {
  // 本地开发
  static const String baseUrl = "http://localhost:8000";
  
  // 生产环境
  // static const String baseUrl = "https://your-app.railway.app";
}
```

### 1.2 认证

所有需要认证的请求需要在 Header 中携带 Token：

```dart
headers: {
  "Authorization": "Bearer $accessToken",
  "Content-Type": "application/json",
}
```

---

## 二、接口调用示例

### 2.1 登录

```dart
// POST /api/auth/login
Future<LoginResponse> login(String username, String password) async {
  final response = await http.post(
    Uri.parse("${ApiConfig.baseUrl}/api/auth/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": username,
      "password": password,
    }),
  );
  
  if (response.statusCode == 200) {
    return LoginResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("登录失败");
  }
}
```

**响应模型**:
```dart
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final User user;
}

class User {
  final int id;
  final String username;
}
```

---

### 2.2 解析日程

```dart
// POST /api/parse
Future<ParseResponse> parseEvent({
  required String inputType,  // "text" 或 "image"
  String? textContent,
  String? imageBase64,
  String? additionalNote,
}) async {
  final response = await http.post(
    Uri.parse("${ApiConfig.baseUrl}/api/parse"),
    headers: _authHeaders(),
    body: jsonEncode({
      "input_type": inputType,
      "text_content": textContent,
      "image_base64": imageBase64,
      "additional_note": additionalNote,
    }),
  );
  
  if (response.statusCode == 200) {
    return ParseResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("解析失败");
  }
}
```

**响应模型**:
```dart
class ParseResponse {
  final List<EventData> events;
  final String parseId;
}

class EventData {
  final int? id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? description;
  final String? sourceType;
  final bool isFollowed;
}
```

---

### 2.3 活动管理

```dart
// GET /api/events
Future<List<EventData>> getEvents({bool followedOnly = false}) async {
  final uri = Uri.parse("${ApiConfig.baseUrl}/api/events")
      .replace(queryParameters: {"followed_only": followedOnly.toString()});
  
  final response = await http.get(uri, headers: _authHeaders());
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data["events"] as List)
        .map((e) => EventData.fromJson(e))
        .toList();
  } else {
    throw Exception("获取活动列表失败");
  }
}

// POST /api/events
Future<EventData> createEvent(EventData event) async {
  final response = await http.post(
    Uri.parse("${ApiConfig.baseUrl}/api/events"),
    headers: _authHeaders(),
    body: jsonEncode(event.toJson()),
  );
  
  if (response.statusCode == 201) {
    return EventData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("创建活动失败");
  }
}

// DELETE /api/events/{id}
Future<void> deleteEvent(int id) async {
  final response = await http.delete(
    Uri.parse("${ApiConfig.baseUrl}/api/events/$id"),
    headers: _authHeaders(),
  );
  
  if (response.statusCode != 204) {
    throw Exception("删除活动失败");
  }
}
```

---

### 2.4 下载 ICS

```dart
// GET /api/events/{id}/ics
Future<void> downloadIcs(int eventId, String filename) async {
  final response = await http.get(
    Uri.parse("${ApiConfig.baseUrl}/api/events/$eventId/ics"),
    headers: _authHeaders(),
  );
  
  if (response.statusCode == 200) {
    // Web: 使用 html.AnchorElement 下载
    // Mobile: 使用 path_provider + share
    await saveFile(response.bodyBytes, "$filename.ics");
  } else {
    throw Exception("下载失败");
  }
}
```

---

## 三、Mock 数据（开发用）

在后端未完成时，前端可使用 Mock 数据进行开发：

```dart
// services/mock_service.dart

class MockService {
  static Future<LoginResponse> login(String username, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    if (username == "alice" && password == "alice123") {
      return LoginResponse(
        accessToken: "mock_token_12345",
        tokenType: "bearer",
        user: User(id: 1, username: "alice"),
      );
    }
    throw Exception("Invalid credentials");
  }
  
  static Future<ParseResponse> parseEvent(String text) async {
    await Future.delayed(Duration(seconds: 2)); // 模拟 AI 处理时间
    
    return ParseResponse(
      events: [
        EventData(
          id: null,
          title: "Mock 会议",
          startTime: DateTime.now().add(Duration(days: 3)),
          endTime: null,
          location: "Mock 地点",
          description: "这是一个 Mock 活动",
          sourceType: "text",
          isFollowed: false,
        ),
      ],
      parseId: "mock-parse-id",
    );
  }
  
  static Future<List<EventData>> getEvents() async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return [
      EventData(
        id: 1,
        title: "汉堡爱乐音乐会",
        startTime: DateTime(2026, 2, 15, 19, 30),
        endTime: DateTime(2026, 2, 15, 22, 0),
        location: "Elbphilharmonie",
        description: "贝多芬第九交响曲",
        sourceType: "image",
        isFollowed: true,
      ),
      EventData(
        id: 2,
        title: "同学聚餐",
        startTime: DateTime(2026, 2, 8, 19, 0),
        endTime: null,
        location: "老地方",
        description: null,
        sourceType: "text",
        isFollowed: true,
      ),
    ];
  }
}
```

---

## 四、任务清单

### P0 - 核心功能

| 任务 ID | 任务描述 | 预估时间 |
|---------|----------|----------|
| FE-01 | 项目结构搭建 + 路由配置 | 1h |
| FE-02 | API 服务层封装（http client + token 管理） | 1h |
| FE-03 | Landing Page 页面 | 1.5h |
| FE-04 | 登录页面 | 1h |
| FE-05 | 主页面布局（底部导航/侧边栏） | 1h |
| FE-06 | 输入页面（文字输入区） | 1h |
| FE-07 | 输入页面（图片上传 + 预览） | 1.5h |
| FE-08 | 日程预览卡片组件 | 1h |
| FE-09 | 日程编辑页面（表单 + 日期时间选择器） | 2h |
| FE-10 | ICS 下载功能 | 0.5h |
| FE-11 | 活动列表页面 | 1h |
| FE-12 | 加载状态 + 错误提示 UI | 1h |

**P0 预估总时间**: 约 12.5 小时

### P1 - 增强功能（可选）

| 任务 ID | 任务描述 | 预估时间 |
|---------|----------|----------|
| FE-13 | 多条日程展示 + 批量操作 | 1.5h |
| FE-14 | 语音录制 + 上传 | 2h |
| FE-15 | Follow Event 功能 | 1h |

---

## 五、页面结构

### 5.1 路由配置

| 路由 | 页面 | 说明 |
|------|------|------|
| `/` | LandingPage | 产品介绍首页 |
| `/login` | LoginPage | 登录页 |
| `/home` | HomePage | 主页（输入入口） |
| `/input` | InputPage | 输入页面 |
| `/preview` | PreviewPage | 日程预览/编辑 |
| `/events` | EventsPage | 活动列表 |

### 5.2 页面组件

#### Landing Page
- Hero Section（产品名 + Slogan + CTA）
- Features Section（功能亮点）
- How It Works（使用流程）
- Footer

#### Login Page
- 用户名输入框
- 密码输入框
- 登录按钮
- 错误提示

#### Input Page
- Tab 切换（文字 / 图片）
- 文字输入区（多行文本框）
- 图片上传区（点击/拖拽上传）
- 补充说明输入框（可选）
- "识别日程" 按钮

#### Preview Page
- 日程卡片展示
- 可编辑字段：
  - 标题（文本输入）
  - 日期（日期选择器）
  - 时间（时间选择器）
  - 地点（文本输入）
  - 描述（多行文本框）
- "保存" / "下载 ICS" 按钮

#### Events Page
- 活动列表（卡片形式）
- 每个卡片显示：标题、时间、地点、倒计时
- 点击进入详情/编辑
- 删除按钮

---

## 六、文件结构

```
lib/
├── main.dart                # 入口
├── config.dart              # 配置（API URL）
├── models/
│   ├── user.dart            # User 模型
│   └── event.dart           # Event 模型
├── services/
│   ├── api_service.dart     # HTTP 请求封装
│   ├── auth_service.dart    # Token 存储/管理
│   └── mock_service.dart    # Mock 数据（开发用）
├── providers/
│   ├── auth_provider.dart   # 认证状态管理
│   └── events_provider.dart # 活动状态管理
├── pages/
│   ├── landing_page.dart
│   ├── login_page.dart
│   ├── home_page.dart
│   ├── input_page.dart
│   ├── preview_page.dart
│   └── events_page.dart
├── widgets/
│   ├── event_card.dart      # 活动卡片
│   ├── input_area.dart      # 输入区域
│   ├── image_picker.dart    # 图片选择器
│   ├── loading_overlay.dart # 加载遮罩
│   └── error_dialog.dart    # 错误弹窗
└── utils/
    ├── date_formatter.dart  # 日期格式化
    └── validators.dart      # 表单验证
```

---

## 七、依赖包

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 网络请求
  http: ^1.1.0
  
  # 状态管理
  provider: ^6.1.1
  
  # 本地存储
  shared_preferences: ^2.2.2
  
  # 图片选择
  image_picker: ^1.0.7
  
  # 文件操作
  path_provider: ^2.1.2
  
  # Web 文件下载
  universal_html: ^2.2.4
  
  # 日期选择器
  intl: ^0.18.1
```

---

## 八、开发顺序建议

1. **FE-01~02**: 项目搭建 + API 层（可与后端并行）
2. **FE-03~05**: 基础页面（Landing, Login, 主页）
3. **FE-06~07**: 输入功能（使用 Mock 数据测试）
4. **FE-08~09**: 预览编辑功能
5. **FE-10~12**: ICS 下载 + 列表 + 完善
6. **联调**: 切换到真实 API

---

## 九、状态管理

使用 Provider 进行简单状态管理：

```dart
// providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  
  User? get user => _user;
  bool get isLoggedIn => _token != null;
  
  Future<void> login(String username, String password) async {
    final response = await ApiService.login(username, password);
    _token = response.accessToken;
    _user = response.user;
    await _saveToken(_token!);
    notifyListeners();
  }
  
  Future<void> logout() async {
    _token = null;
    _user = null;
    await _clearToken();
    notifyListeners();
  }
}
```

---

*最后更新：2026-01-31*
