# FollowUP 后端开发计划

> 技术栈：Python + FastAPI + SQLAlchemy + LangChain + OpenAI

---

## 一、API 接口规范

### 1.1 认证接口

#### POST /api/auth/login
用户登录，返回 JWT Token

**请求体**:
```json
{
  "username": "alice",
  "password": "alice123"
}
```

**响应 200**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "username": "alice"
  }
}
```

**响应 401**:
```json
{"detail": "Invalid credentials"}
```

---

#### GET /api/user/me
获取当前用户信息

**Header**: `Authorization: Bearer <token>`

**响应 200**:
```json
{
  "id": 1,
  "username": "alice",
  "created_at": "2026-01-31T10:00:00Z"
}
```

---

### 1.2 日程解析接口

#### POST /api/parse
解析文字或图片中的日程信息

**Header**: `Authorization: Bearer <token>`

**请求体**:
```json
{
  "input_type": "text",
  "text_content": "下周三下午2点开会",
  "image_base64": null,
  "additional_note": "在星巴克"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| input_type | string | 是 | "text" 或 "image" |
| text_content | string | 否 | 文字内容 |
| image_base64 | string | 否 | 图片 base64 编码 |
| additional_note | string | 否 | 补充说明 |

**响应 200**:
```json
{
  "events": [
    {
      "id": null,
      "title": "开会",
      "start_time": "2026-02-05T14:00:00+08:00",
      "end_time": null,
      "location": "星巴克",
      "description": null,
      "source_type": "text",
      "is_followed": false
    }
  ],
  "parse_id": "uuid-xxx"
}
```

---

### 1.3 活动管理接口

#### GET /api/events
获取用户的活动列表

**Header**: `Authorization: Bearer <token>`

**Query 参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| followed_only | bool | 仅返回已 Follow 的活动 |

**响应 200**:
```json
{
  "events": [
    {
      "id": 1,
      "title": "汉堡爱乐音乐会",
      "start_time": "2026-02-15T19:30:00+01:00",
      "end_time": "2026-02-15T22:00:00+01:00",
      "location": "Elbphilharmonie",
      "description": "贝多芬第九交响曲",
      "is_followed": true,
      "created_at": "2026-01-31T10:00:00Z"
    }
  ]
}
```

---

#### POST /api/events
创建/保存活动

**Header**: `Authorization: Bearer <token>`

**请求体**:
```json
{
  "title": "开会",
  "start_time": "2026-02-05T14:00:00+08:00",
  "end_time": null,
  "location": "星巴克",
  "description": "记得带PPT",
  "source_type": "text",
  "is_followed": true
}
```

**响应 201**: 返回创建的 event 对象

---

#### PUT /api/events/{id}
更新活动

**Header**: `Authorization: Bearer <token>`

**请求体**: 同 POST，字段可选

**响应 200**: 返回更新后的 event 对象

---

#### DELETE /api/events/{id}
删除活动

**Header**: `Authorization: Bearer <token>`

**响应 204**: 无内容

---

#### GET /api/events/{id}/ics
下载活动的 ICS 文件

**Header**: `Authorization: Bearer <token>`

**响应 200**:
- Content-Type: `text/calendar`
- Content-Disposition: `attachment; filename="event.ics"`
- Body: ICS 文件内容

---

### 1.4 健康检查

#### GET /api/health

**响应 200**:
```json
{"status": "healthy"}
```

---

## 二、数据库模型

### User 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| username | String(50) | 用户名，唯一 |
| password_hash | String(255) | 密码哈希 |
| created_at | DateTime | 创建时间 |

### Event 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| user_id | Integer | 外键 -> users.id |
| title | String(255) | 活动标题 |
| start_time | DateTime | 开始时间 |
| end_time | DateTime | 结束时间（可空） |
| location | String(500) | 地点（可空） |
| description | Text | 描述（可空） |
| source_type | String(50) | 来源类型：text/image/voice |
| source_content | Text | 原始输入内容 |
| is_followed | Boolean | 是否已 Follow |
| created_at | DateTime | 创建时间 |

### 预置用户

| Username | Password |
|----------|----------|
| alice | alice123 |
| bob | bob123 |
| jane | jane123 |
| xiao | xiao123 |

---

## 三、任务清单

### P0 - 核心功能

| 任务 ID | 任务描述 | 预估时间 |
|---------|----------|----------|
| BE-01 | 项目结构搭建（FastAPI + SQLAlchemy + SQLite） | 1h |
| BE-02 | 数据库模型定义（User, Event） | 0.5h |
| BE-03 | 预置用户初始化脚本 | 0.5h |
| BE-04 | 用户认证接口（POST /api/auth/login） | 1h |
| BE-05 | JWT Token 验证中间件 | 0.5h |
| BE-06 | 获取当前用户接口（GET /api/user/me） | 0.5h |
| BE-07 | LangChain 集成 + Prompt 模板 | 1.5h |
| BE-08 | 文字解析接口（POST /api/parse - text） | 1h |
| BE-09 | 图片解析接口（POST /api/parse - image） | 1h |
| BE-10 | 活动 CRUD 接口（GET/POST/PUT/DELETE /api/events） | 1.5h |
| BE-11 | ICS 文件生成接口（GET /api/events/{id}/ics） | 1h |
| BE-12 | CORS 配置 + 错误处理 | 0.5h |

**P0 预估总时间**: 约 10 小时

### P1 - 增强功能（可选）

| 任务 ID | 任务描述 | 预估时间 |
|---------|----------|----------|
| BE-13 | 多条日程批量解析 | 1h |
| BE-14 | 语音转文字（Whisper API） | 1.5h |
| BE-15 | WebSocket 流式响应 | 2h |

---

## 四、文件结构

```
Backend/
├── main.py              # FastAPI 入口
├── config.py            # 配置（DB URL, JWT Secret, OpenAI Key）
├── database.py          # SQLAlchemy 连接
├── models.py            # 数据库模型
├── schemas.py           # Pydantic 请求/响应模型
├── auth.py              # JWT 认证逻辑
├── routers/
│   ├── __init__.py
│   ├── auth.py          # /api/auth/*
│   ├── users.py         # /api/user/*
│   ├── events.py        # /api/events/*
│   └── parse.py         # /api/parse
├── services/
│   ├── __init__.py
│   ├── llm_service.py   # LangChain 集成
│   └── ics_service.py   # ICS 生成
└── requirements.txt
```

---

## 五、环境变量

```bash
# .env
DATABASE_URL=sqlite:///./followup.db
JWT_SECRET=your-secret-key-here
JWT_ALGORITHM=HS256
JWT_EXPIRE_HOURS=24
OPENAI_API_KEY=sk-xxx
```

---

## 六、开发顺序建议

1. **BE-01~03**: 项目搭建 + 数据库（可与前端并行）
2. **BE-04~06**: 认证模块（前端登录页依赖）
3. **BE-07~09**: 解析接口（核心功能）
4. **BE-10~11**: 活动管理 + ICS（前端联调需要）
5. **BE-12**: 收尾完善

---

*最后更新：2026-01-31*
