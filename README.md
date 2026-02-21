# 亏了啥

> 一个帮你记录亏损的 App，用「损失厌恶理论」时刻提醒自己。

## 简介

**亏了啥** 是一款基于 Flutter 的跨平台应用（Android / Web），专注于记录日常生活中的各种亏损——股票、基金、加密货币、发红包、随礼、瞎投资……帮你看清钱到底亏在了哪里。

首页融入心理学「损失厌恶理论」（Kahneman & Tversky, 1979），让每一笔亏损都更有"痛感"，从而辅助你做出更理性的财务决策。

## 功能

- **记录亏损**：金额、分类、备注、日期，一笔一笔清清楚楚
- **预设分类**：股票、基金、加密货币、期货、房产、创业、借钱不还了、发红包、随礼、瞎投资、其他
- **本地存储**：基于 Hive，数据保存在本地，无需联网
- **CSV 导出/导入**：支持导出为 CSV 文件，方便备份或迁移到其他工具
- **跨平台**：Android APK + Web 端均可使用
- **损失厌恶洞察**：首页展示基于你亏损数据的心理学洞察

## 截图

UI 采用 Apple Liquid Glass 风格设计，深色渐变背景 + 半透明毛玻璃卡片。

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter (Dart) |
| 本地存储 | Hive + hive_flutter |
| CSV 处理 | csv ^7.1.0 |
| 文件操作 | file_picker / path_provider / share_plus |
| 唯一 ID | uuid |
| 日期格式化 | intl |
| Web 支持 | web (dart:js_interop) |

## 项目结构

```
lib/
├── main.dart                  # 入口 & 主题配置
├── models/
│   └── transaction.dart       # 亏损记录数据模型
├── pages/
│   ├── home_page.dart         # 首页（汇总 + 列表 + 洞察卡片）
│   └── add_edit_page.dart     # 新增/编辑亏损
├── services/
│   ├── storage_service.dart   # Hive 本地存储
│   ├── csv_service.dart       # CSV 导出/导入
│   ├── file_service.dart      # 文件服务抽象层
│   ├── file_service_io.dart   # 移动端文件实现
│   ├── file_service_web.dart  # Web 端文件实现
│   └── file_service_stub.dart # 平台兜底实现
└── widgets/
    └── glass_card.dart        # Liquid Glass 毛玻璃组件
```

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.11.0
- Dart ≥ 3.11.0
- Android SDK 35（构建 APK 时需要）
- JDK 17

### 运行

```bash
# 安装依赖
flutter pub get

# Web 端运行
flutter run -d chrome

# Android 端运行（需连接设备或模拟器）
flutter run -d android
```

### 构建 APK

```bash
flutter build apk --release
```

产物路径：`build/app/outputs/flutter-apk/app-release.apk`

## 许可证

本项目为个人工具，未指定开源许可证。
