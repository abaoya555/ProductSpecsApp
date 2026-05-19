# 产品规格库 iOS App

这是一个 SwiftUI 原生 iPhone App 第一版，适合用 GitHub Actions 云端编译，然后用 TrollStore 安装。

## 第一版功能

- 添加产品
- 产品照片
- 产品名
- 规格/重量
- 分类
- 包装
- 长宽高
- 自动计算 CBM 方数
- 搜索
- 详情页
- 一键复制客户规格
- 本地 JSON 保存
- 图片保存到 App Documents/images
- 备份：复制 JSON 到剪贴板

## Windows 用户怎么用

1. 注册或登录 GitHub。
2. 新建仓库，例如 `ProductSpecsApp`。
3. 把本文件夹里的所有内容上传到仓库根目录。
4. 打开仓库的 `Actions`。
5. 选择 `Build iOS IPA`。
6. 点 `Run workflow`。
7. 编译完成后，在 Artifacts 下载 `ProductSpecsApp_unsigned_ipa`。
8. 解压得到 `.ipa`。
9. 传到 iPhone，用 TrollStore 安装。

## 注意

- 这个包是 unsigned IPA，主要给 TrollStore 路线用。
- 如果你要正常 App Store / TestFlight，需要 Apple Developer 证书和描述文件。
- GitHub Actions 使用 macOS runner 来编译 iOS App。
