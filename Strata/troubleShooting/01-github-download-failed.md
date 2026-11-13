# 问题: GitHub 下载失败

## 日期
2026-11-12

## 问题描述
从 GitHub 下载 Strata Terminal (strata-control-0.1.59.1-linux-x86_64.tar.gz) 时失败。

## 错误信息
```
curl: (92) HTTP/2 stream 0 was not closed cleanly: PROTOCOL_ERROR (err 1)
strata installer: the download failed. Check your internet connection and run this again
```

使用 HTTP/1.1 强制模式:
```
curl: (56) OpenSSL SSL_read: error:0A000126:SSL routines::unexpected eof while reading, errno 0
```

## 原因分析
1. 网络连接到 GitHub 不稳定
2. 可能是防火墙或代理问题
3. SSL/TLS 连接中断

## 解决方案

### 方案 1: 使用代理
```bash
export https_proxy=http://your-proxy:port
./install-strata.sh
```

### 方案 2: 从源码构建
```bash
cd Strata-main
./setup.sh --setup
```

### 方案 3: 手动下载
1. 在能访问 GitHub 的机器上下载
2. 传输到目标机器
3. 手动解压安装

### 方案 4: 使用镜像
如果有 HuggingFace 镜像或其他 CDN:
```bash
# 从 HuggingFace 下载模型文件
huggingface-cli download ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF
```

## 状态
⏳ 待解决 - 需要网络环境支持
