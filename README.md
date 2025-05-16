Supported tags and respective `Dockerfile` links
================================================

  * [`latest` (Dockerfile)](https://github.com/BakasuraRCE/openvpn-dante/blob/master/Dockerfile)


How to use this image
-------------

You can use this image at same form that [dperson image](https://github.com/dperson/openvpn-client)
Additional this expose the `1080` port as socks5 proxy server

Example Compose File
-------------

```
version: "3.8"

version: "3.8"

services:
  vpn:
    # 本地构建
    build:
      context: .
      dockerfile: Dockerfile
    image: openvpn-dante:local
    # 如果需要 IPv6
    # sysctls:
    #   net.ipv6.conf.all.disable_ipv6: 0
    cap_add:
      - NET_ADMIN
    cap_drop:
      - CAP_MKNOD
    environment:
      # 时区
      TZ: "Etc/GMT-2"
      # 保留原来的选项
      FIREWALL: ""
      GROUPID: "1000"
      # 以下两行示例了如何启用 SOCKS5 用户认证
      # 不需要认证可留空或注释掉
      SOCKS_USER: your_socks_username
      SOCKS_PASS: your_socks_password
    ports:
      - "1080:1080"
    volumes:
      # 挂载 tun 设备
      - /dev/net:/dev/net:z
      # 本地放置 .ovpn 配置文件的目录
      - ./vpn:/vpn
    # 本地调试时，直接重启失败的容器即可
    restart: on-failure

```
