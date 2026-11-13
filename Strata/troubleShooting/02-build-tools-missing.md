# 问题: 无法从源码编译 Strata 引擎

## 日期
2026-11-12

## 问题描述
尝试从源码编译 Strata 引擎失败，缺少必要的构建工具。

## 错误信息
1. `./setup.sh --build` 仍然需要从 GitHub 下载工具
2. 缺少 cmake: `cmake not found`
3. 缺少 CUDA toolkit: `nvcc not found`

## 原因分析
1. 源码编译需要 cmake 3.24+ 和 CUDA toolkit
2. 当前系统未安装这些工具
3. GitHub 网络访问受限，无法下载预构建引擎

## 解决方案

### 方案 1: 安装构建工具
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install cmake nvidia-cuda-toolkit

# 或使用 NVIDIA 官方安装包
# https://developer.nvidia.com/cuda-downloads
```

### 方案 2: 使用代理访问 GitHub
```bash
export HTTPS_PROXY=http://your-proxy:port
./setup.sh --family coder --model IQ1_M --source modelscope
```

### 方案 3: 手动下载引擎
1. 在能访问 GitHub 的机器上下载:
   - strata-engine-cuda13-linux-x86_64.tar.gz
2. 传输到目标机器
3. 使用 --prebuilt 选项指定路径

### 方案 4: 使用 pip 安装 (如果有)
```bash
pip install strata-engine
```

## 需要的工具
| 工具 | 版本要求 | 用途 |
|------|----------|------|
| cmake | 3.24+ | 构建系统 |
| CUDA toolkit | 12 或 13 | GPU 编译 |
| C++20 编译器 | gcc 11+ / clang 14+ | 编译 |
| Python | 3.10+ | 运行脚本 |

## 状态
⏳ 待解决 - 需要安装构建工具或解决网络问题
