# 问题: GitHub 访问超时 - 已解决

## 日期
2026-11-12

## 问题描述
从 GitHub 下载 Strata 引擎和组件时超时。

## 解决方案
**开启 VPN 后问题解决**

```bash
# 开启 VPN 后直接运行
./setup.sh --family coder --model IQ1_M --data-dir /data1/disk2/strata/models --source modelscope --setup --yes
```

## 备选方案（如果 VPN 不可用）

### 方案 1: 使用 GitHub 镜像
```bash
# gh-proxy.com 可用
export GITHUB_PROXY="https://gh-proxy.com/https://github.com"
```

### 方案 2: 手动下载引擎
```bash
# 下载预构建引擎
curl -L "https://gh-proxy.com/https://github.com/Niko1221/Strata/releases/latest/download/strata-control-0.1.59.1-linux-x86_64.tar.gz" -o /tmp/strata-engine.tar.gz

# 解压到组件目录
mkdir -p ~/.local/share/strata/components
tar -xzf /tmp/strata-engine.tar.gz -C ~/.local/share/strata/components
```

## 状态
✅ 已解决 - VPN 开启后正常下载
