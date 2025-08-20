# FRPC (sunboss) – Home Assistant 插件

在 Home Assistant 中运行 **frp client (frpc)**。支持 **多个 FRPS 服务器**、**每个服务器多个代理/端口**，并支持多 CPU 架构。插件会把你的 Options 配置自动转换为多个 `frpc.ini`（每个服务器一个），并分别启动进程。

## 特性
- `servers` 数组：可配置多个 FRPS（如主用/备用），**每个服务器一个 frpc 进程**；
- `proxies` 数组：同一服务器下可配置多个 TCP/UDP/HTTP/HTTPS/STCP/SUDP/XTCP 代理；
- `additional_params`：可注入任意原生 frpc 配置行（`key=value`）；
- 支持 `amd64/aarch64/armv7/armhf/i386` 多平台构建与运行。

## 配置示例

```yaml
servers:
  - name: main
    server_addr: "frps.example.com"
    server_port: 7000
    token: "YOUR_TOKEN"
    user: "ha"
    log_level: info
    proxies:
      - name: "ssh"
        type: "tcp"
        local_ip: "127.0.0.1"
        local_port: 22
        remote_port: 6000

      - name: "ha-http"
        type: "http"
        local_ip: "127.0.0.1"
        local_port: 8123
        subdomain: "home"
        # 或使用 custom_domains：
        # custom_domains: ["ha.example.com"]
        additional_params:
          - "health_check_type=tcp"
          - "health_check_timeout_s=3"

  - name: backup
    server_addr: "backup-frps.example.org"
    server_port: 7000
    token: "OTHER_TOKEN"
    log_level: warn
    proxies:
      - name: "rdp"
        type: "tcp"
        local_ip: "192.168.1.10"
        local_port: 3389
        remote_port: 63389
```

保存并启动插件。每个 `servers[].name` 会生成一个 `data/frpc/<name>.ini`，对应一个 frpc 进程。

## 提示
- **HTTP/HTTPS 域名反代**：用 `type: http/https` + `subdomain` 或 `custom_domains`；
- **更多 frpc 参数**：写入 `additional_params`，会被原样追加到该代理配置段；
- **日志**：在插件详情页 → 日志查看。

---

## 当前版本：v2025.08.20-01

**维护者**：sunboss <sunboss@qq.com>
