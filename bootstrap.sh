#!/bin/sh

# 如果任意后台进程失败则退出
set -e

# 启动 OpenVPN 客户端
/usr/bin/openvpn.sh &
openvpn_pid=$!

# 等待 VPN 建立
sleep 15

# 如果定义了认证环境变量，则生成密码文件并强制启用用户名认证
if [ -n "${SOCKS_USER:-}" ] && [ -n "${SOCKS_PASS:-}" ]; then
  echo "启用 SOCKS5 用户名/密码认证：${SOCKS_USER}"
  # 写入 passwd 文件
  cat >/etc/sockd.passwd <<EOF
${SOCKS_USER}:${SOCKS_PASS}
EOF
  chmod 600 /etc/sockd.passwd

  # 更新配置：去掉回落到 none 的那部分，强制 username
  sed -i \
    -e 's/socksmethod: username none/socksmethod: username/' \
    /etc/sockd.conf
fi

# 启动 Dante SOCKS5 代理（引用 /etc/sockd.conf）
sockd -f /etc/sockd.conf -N "$(nproc --all)" &
sockd_pid=$!

# 等待两个后台进程退出，保持容器存活
wait "${openvpn_pid}"
wait "${sockd_pid}"
