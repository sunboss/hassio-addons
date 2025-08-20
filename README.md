# Sunboss 的 Home Assistant 插件库

这里提供 **FRPC（frp client）** 的 Home Assistant 插件，支持**多服务器**与**多端口/多代理**配置，并适配多平台（amd64/aarch64/armv7/armhf/i386）。

## 在 Home Assistant 中添加仓库
1. 进入：**设置 → 插件 → 插件商店 → 右上角 ⋮ → Repositories（仓库）**；
2. 粘贴仓库地址：`https://github.com/sunboss/hassio-addons` 然后点击 **Add**；
3. 打开 **FRPC (sunboss)**，安装 → 配置 → 启动。

---

## 当前版本：v2025.08.20-01

### 开发者（可选）：启用 GHCR 自动构建
本仓库包含 GitHub Actions 工作流，用于构建并推送镜像到 **GitHub Container Registry (GHCR)**。

- 推送目标（按架构）：`ghcr.io/sunboss/frpc-{arch}`（其中 `{arch}` 为 `amd64|aarch64|armv7|armhf|i386`）
- 默认还会推送一个多架构清单到：`ghcr.io/sunboss/frpc:latest`（用于通用拉取与调试）

### 触发方式
- 推送到 `main` 分支：产出 `:edge` 标签；
- 推送带 `v*` 的 tag（例如 `v1.0.0`）：为每个架构产出 `:1.0.0` 与 `:latest`；
