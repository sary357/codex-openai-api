# --- 基本設定 ---
sudo yum update -y
sudo yum install -y docker
sudo usermod -a -G docker ec2-user
sudo service docker start

# --- 準備系統層級的 CLI plugins 目錄 ---
export SYS_DOCKER_PLUGINS=/usr/local/lib/docker/cli-plugins
sudo mkdir -p "$SYS_DOCKER_PLUGINS"

# --- 安裝 docker compose (system-wide) ---
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  DC_ARCH=linux-x86_64 ;;
  aarch64) DC_ARCH=linux-aarch64 ;;
  *) echo "Unknown arch: $ARCH" >&2; exit 1 ;;
esac
DC_VER=v5.1.4 # 可以到 https://github.com/docker/compose/releases 查看最新版本並更新
curl -sSL \
  "https://github.com/docker/compose/releases/download/${DC_VER}/docker-compose-${DC_ARCH}" \
  -o "$SYS_DOCKER_PLUGINS/docker-compose"
chmod +x "$SYS_DOCKER_PLUGINS/docker-compose"

# --- 安裝 buildx (system-wide) ---
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  BX_ARCH=linux-amd64 ;;
  aarch64) BX_ARCH=linux-arm64 ;;
  *) echo "Unknown arch: $ARCH" >&2; exit 1 ;;
esac
BX_VER=v0.34.1 # 可以到 https://github.com/docker/buildx/releases 查看最新版本並更新
sudo curl -sSL \
  "https://github.com/docker/buildx/releases/download/${BX_VER}/buildx-${BX_VER}.${BX_ARCH}" \
  -o "$SYS_DOCKER_PLUGINS/docker-buildx"
sudo chmod +x "$SYS_DOCKER_PLUGINS/docker-buildx"

# --- 版本確認 ---
docker --version
docker buildx version
docker compose version
