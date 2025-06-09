# 图书馆座位预约系统

## 项目简介

本项目为一套基于 Flutter + Dart + Shelf + SQLite 的图书馆座位预约系统，采用前后端分离架构，支持用户注册、登录、座位查询、预约及预约记录查询等功能。前端为 Flutter 跨平台移动应用，后端为 Dart Shelf 框架开发的 RESTful API 服务，数据持久化采用 SQLite。

---

## 技术栈

- **前端**：Flutter、Dart、HTTP
- **后端**：Dart、Shelf、SQLite
- **数据库**：SQLite

---

## 目录结构

```
clsr_system/
├── clsr_customer/    # Flutter 前端
│   └── lib/
│       └── clsr_customer.dart
├── clsr_server/      # Dart 后端
│   └── bin/
│       └── clsr_server.dart
└── clsr_db.sqlite    # SQLite 数据库文件（运行后自动生成）
```

---

## 快速开始

### 1. 后端启动

1. 进入后端目录：
   ```shell
   cd clsr_server/bin
   ```
2. 安装依赖（如未安装）：
   ```shell
   dart pub get
   ```
3. 启动服务：
   ```shell
   dart clsr_server.dart
   ```
   启动成功后，终端会显示：
   ```
   Server listening on port 8080
   ```

### 2. 前端启动

1. 进入前端目录：
   ```shell
   cd clsr_customer
   ```
2. 安装依赖：
   ```shell
   flutter pub get
   ```
3. 运行应用（以 Android 模拟器为例）：
   ```shell
   flutter run
   ```
   > 注意：前端默认通过 `http://10.0.2.2:8080` 访问后端接口，适用于 Android 模拟器。如需在真机或其他环境运行，请将接口地址改为实际主机 IP。

---

## 主要功能

- 用户注册与登录
- 座位列表查询、筛选与详情查看
- 座位预约（含时间段选择、冲突检测）
- 预约记录查询
- 个人中心与退出登录

---

## 数据库说明

- 首次启动后端时，会自动在 `clsr_server/bin` 目录下生成 `clsr_db.sqlite` 文件。
- 可使用 [DB Browser for SQLite](https://sqlitebrowser.org/) 或命令行工具查看和管理数据。

---

## 常见问题

- **前端无法连接服务器**  
  请确保后端已启动，端口未被防火墙拦截，前端接口地址正确（模拟器用 `10.0.2.2`，真机用主机实际 IP）。

- **如何查看数据库内容？**  
  进入 `clsr_server/bin` 目录，使用命令行：
  ```shell
  sqlite3 clsr_db.sqlite
  ```
  查看表：
  ```sql
  .tables
  SELECT * FROM users;
  ```

---

## 项目亮点

- 前后端完全分离，接口设计规范
- Flutter 跨平台开发，界面简洁易用
- 后端基于 Dart Shelf，轻量高效
- SQLite 本地数据库，部署与维护简单

---

## 联系方式

如有问题或建议，欢迎联系项目作者。