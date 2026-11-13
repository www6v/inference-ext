# Strata 项目深度分析报告

> 分析日期：2026-11-11
> 项目路径：`Strata-main/`
> 版本：0.2.13（引擎版本 0.1.59.1）

---

## 目录

- [一、项目概述](#一项目概述)
  - [核心定位](#核心定位)
  - [项目三大部分](#项目三大部分)
- [二、目录结构详解](#二目录结构详解)
  - [根目录关键文件](#根目录关键文件)
  - [核心源码目录](#核心源码目录)
  - [支撑目录](#支撑目录)
- [三、核心架构分析](#三核心架构分析)
  - [3.1 模型几何结构](#31-模型几何结构以-qwen38-flash-next-为例)
  - [3.2 单 Token 生成数据流](#32-单-token-生成数据流)
  - [3.3 核心创新：Doorbell 协议](#33-核心创新doorbell-协议)
  - [3.4 CUDA Graph 捕获](#34-cuda-graph-捕获)
  - [3.5 内存架构](#35-内存架构)
- [四、DeepSeek-V4.1 引擎](#四deepseek-v41-引擎)
- [五、多平台后端支持](#五多平台后端支持)
  - [5.1 后端矩阵](#51-后端矩阵)
  - [5.2 支持的 GPU 列表](#52-支持的-gpu-列表)
  - [5.3 Metal 后端](#53-metal-后端-metal)
  - [5.4 SYCL 后端](#54-sycl-后端-sycl)
  - [5.5 HIP 后端](#55-hip-后端)
- [六、API 服务器 (serve/)](#六api-服务器-serve)
  - [6.1 兼容接口](#61-兼容接口)
  - [6.2 核心组件](#62-核心组件)
- [七、CLI 工具 (strata_cli/)](#七cli-工具-strata_cli)
  - [7.1 子命令](#71-子命令)
  - [7.2 关键模块](#72-关键模块)
- [八、构建系统](#八构建系统)
  - [8.1 CMake 构建（C++ 引擎）](#81-cmake-构建c-引擎)
  - [8.2 Python 安装 (setup.py)](#82-python-安装-setuppy)
  - [8.3 Python 依赖](#83-python-依赖)
- [九、容器化部署](#九容器化部署)
  - [9.1 两套 Dockerfile](#91-两套-dockerfile)
  - [9.2 Docker 基础设施](#92-docker-基础设施)
  - [9.3 根 Dockerfile 构建流程](#93-根-dockerfile-构建流程)
- [十、打包与分发](#十打包与分发)
  - [10.1 打包工具集](#101-打包工具集)
  - [10.2 目标平台矩阵](#102-目标平台矩阵)
  - [10.3 安全机制](#103-安全机制)
- [十一、CI/CD 流水线](#十一cicd-流水线)
  - [11.1 GitHub Actions 工作流](#111-github-actions-工作流12-个)
  - [11.2 测试策略](#112-测试策略)
- [十二、核心技术特性](#十二核心技术特性)
  - [12.1 推测解码](#121-推测解码)
  - [12.2 关键技术亮点](#122-关键技术亮点)
- [十三、文档体系](#十三文档体系)
- [十四、第三方依赖](#十四第三方依赖)
- [十五、总结与评价](#十五总结与评价)
  - [优势](#优势)
  - [适用场景](#适用场景)
  - [技术门槛](#技术门槛)
- [十六、工具集成](#十六工具集成)
  - [16.1 支持的 AI 编码工具](#161-支持的-ai-编码工具)
  - [16.2 MCP 支持](#162-mcp-model-context-protocol-支持)
- [十七、项目规模统计](#十七项目规模统计)
- [十八、Docker 镜像](#十八docker-镜像)

---

## 一、项目概述

**Strata** 是一个开源的高性能本地 AI 推理引擎，专为在消费级硬件上运行大型语言模型（LLM）而设计。它支持多种模型系列和 diverse GPU 后端，提供从桌面应用到命令行的完整使用体验。

### 核心定位

| 维度 | 描述 |
|------|------|
| **目标** | 本地高性能 LLM 推理，支持 MoE（Mixture of Experts）大模型 |
| **支持模型** | Qwen3.8-Flash-Next, DeepSeek V4.1-Flash, Qwen3.6-35B-A3B, Swift 1.5 |
| **GPU 后端** | NVIDIA CUDA, AMD HIP, Intel SYCL, Apple Metal, CPU (AVX2) |
| **三大组成** | 桌面应用 (Tauri) + 终端 CLI + C++ 推理引擎 |
| **开源协议** | MIT License, Copyright 2026 Niko1221 and contributors |

**核心价值主张**：像 Qwen3.8-Flash-Next 这样的模型通常需要数百 GB VRAM，Strata 通过智能分配 GPU VRAM、系统 RAM、CPU 和 SSD 的工作负载，使其能在消费级 GPU（12-24 GB）上运行。

### 项目三大部分

```
┌─────────────────────────────────────────────────────────┐
│                    Strata 项目结构                        │
├─────────────────┬──────────────────┬────────────────────┤
│   桌面应用       │    终端 CLI       │    推理引擎+服务    │
│  apps/desktop/  │  strata_cli/     │  src/ + include/   │
│  apps/host/     │  strata.py       │  serve/            │
│  (Tauri + Web)  │  strata_control/ │  metal/ sycl/      │
└─────────────────┴──────────────────┴────────────────────┘
```

---

## 二、目录结构详解

### 根目录关键文件

| 文件/目录 | 说明 |
|-----------|------|
| `strata.py` | 无依赖入口点（仅 stdlib），路由命令到 `strata_cli/` |
| `CMakeLists.txt` | C++20 CMake 构建系统主文件 |
| `setup.py` | 728KB 的一键安装/部署脚本（Windows + Linux） |
| `setup.sh` / `START-HERE.bat` | Linux / Windows 启动脚本 |
| `requirements*.txt` | Python 依赖（运行时、构建、开发、监控等） |
| `flake.nix` | Nix 开发环境配置 |

### 核心源码目录

| 目录 | 功能 |
|------|------|
| `src/core/` | 核心引擎：会话管理、层执行、权重加载、设备管理 |
| `src/kernels/` | GPU kernel 实现（100+ 文件：GEMV, attention, MoE, 量化, 采样） |
| `src/dsv41/` | DeepSeek-V4.1 引擎（672B 参数 MoE 模型，SSD expert 流式加载） |
| `src/prefill/` | Prefill kernel（GEMM, MoE workspace, WMMA） |
| `src/program/` | 高层生成循环、draft KV 规划、batch 管理 |
| `src/spec/` | 推测解码（suffix drafter, draft policy, 验证） |
| `src/qwen35/` | Qwen3.6-35B-A3B 引擎路径 |
| `src/plan/` | 内存规划器和 census |
| `src/artifact/` | GGUF 读取器、模型族检测、反量化 |
| `src/ngram/` | N-gram draft 模型读取器 |
| `src/platform/` | OS 抽象层（内存、文件 I/O、线程、CPU 亲和性） |
| `src/split/` | 多 GPU 层分割 |
| `include/strata/` | 60+ 头文件，定义完整 C++ API |

### 支撑目录

| 目录 | 功能 |
|------|------|
| `serve/` | Python API 服务器（OpenAI/Anthropic 兼容接口） |
| `strata_cli/` | 终端 CLI（serve, launch, connect, monitor, bench, tune） |
| `strata_control/` | 系统配置层（GPU 选择、引擎管理、调优） |
| `apps/desktop/` | Tauri 桌面应用 shell |
| `apps/host/` | Node.js 主机服务 + Web UI |
| `metal/` | Apple Metal 后端（独立 CMake 项目） |
| `sycl/` | Intel SYCL 后端（独立 CMake 项目） |
| `spark/` | NVIDIA DGX Spark 支持 |
| `third_party/` | 第三方依赖（strata-ggml, ggml, sfnx, project-maya 等） |
| `integrations/` | 测试集成和 harness |
| `packaging/` | 打包发布系统 |
| `docker/` | 生产容器基础设施 |
| `data/` | 引擎二进制数据（词表、expert profile 等） |
| `docs/` | 完整文档（174KB 技术细节 + 各平台指南） |
| `research/` | 研究实验代码 |
| `history/` | 历史存档 |

---

## 三、核心架构分析

### 3.1 模型几何结构（以 Qwen3.8-Flash-Next 为例）

```
48 层 Transformer
├── 36 层 GDN (Gated Delta Net) — 线性注意力，delta-rule 递推
└── 12 层 QSA (Full Attention)  — 位置 3,7,11,...,47（每4层一个）

每层结构：
┌──────────────────────────────────────────────────┐
│  gr_read → Mixer (GDN/QSA) → gr_write           │
│  gr_read → MoE (512 experts, top-10) → gr_write  │
│  Gated Residual: 4-stream 超连接，低秩瓶颈 320    │
└──────────────────────────────────────────────────┘

关键参数：
- 词表大小：248,320 tokens
- Embedding 维度：2560
- MoE：512 experts / token 使用 10 个，FFN 宽度 640
- GDN：128 state size, 16 K-heads, 48 V-heads
- QSA：24 query heads, 2 KV heads, 256 head dim
```

### 3.2 单 Token 生成数据流

```
1. Embedding
   embed_row() — 从量化 embedding 表列反量化

2. 48 层循环（每层）：
   ┌─ gr_read(attn) — 4-stream 残差折叠为单向量
   │
   ├─ Mixer:
   │  ├─ GDN: qkv投影 → conv1d → SiLU → l2_norm → delta-rule递推 → 输出归一化
   │  └─ QSA: q/k/v投影 → KV追加 → indexer → block scores → top-k → softmax → gate
   │
   ├─ gr_write(attn) — 散射回 4 个残差流
   ├─ gr_read(ffn)  — 折叠残差给 MoE
   │
   ├─ MoE:
   │  BF16 router GEMV → top-k选择 → doorbell发布 → shared expert → combine
   │
   └─ gr_write(ffn) — 散射回残差流

3. LM Head
   lm_head() — 最终 GR read + 输出投影到词表 logits

4. Sampling
   temperature, top-p, top-k, min-p 采样
```

### 3.3 核心创新：Doorbell 协议

Strata 的关键创新在于 **CPU-GPU 重叠执行 MoE expert 计算**：

```
时间线：
─────────────────────────────────────────────────────→

GPU:  [pre layer l: attn → mixer → gr_write → ffn_gr_read → moe_route]
                                                                    ↓ ring doorbell
CPU:                                              [pool: 计算 expert 输出]
                                                                    ↓
GPU:  [post layer l: moe_finish → gr_write]
```

**工作原理**：
- `Doorbell` 结构使用映射的 pinned 内存（一个设备地址 + 一个主机地址）
- GPU 写入路由结果；主机通过 `cudaEventQuery` 轮询（**永不阻塞同步**）
- CPU pool 获得约 **29% 层执行时间** 来计算 expert 输出
- 这使得在有限 VRAM 中运行超大 MoE 模型成为可能

### 3.4 CUDA Graph 捕获

引擎按层捕获 CUDA graph 以减少 kernel launch 开销：
- 每层两个 graph：`pre[l]`（到 router）和 `post[l]`（pool 之后）
- 测量到 **1.51x 加速**（从 graph replay）
- `TokenGraph` 变体将全部 48 层捕获在一个 graph 中

### 3.5 内存架构

```
VRAM 预算：~5.95 GB（KV cache + expert cache）
DRAM：     33.97 GB（expert 权重从存储流式加载）

DeviceArena：单次 cudaMalloc + bump 分配，无 free
             内存计划在启动时固定

Expert Cache：
├── VRAM 常驻 slot（频繁使用的 expert）
└── Miss → CPU pool（从 DRAM/SSD 加载）
```

---

## 四、DeepSeek-V4.1 引擎

独立的引擎路径，处理 672B 参数 MoE 模型：

| 特性 | 说明 |
|------|------|
| **Expert 流式加载** | SSD 基于 expert 流式传输，可配置 LRU/LFU 缓存策略 |
| **对话 Slot** | 跨请求保存/恢复完整对话状态 |
| **共享前缀缓存** | 公共系统提示的 KV cache 复用 |
| **DSpark 推测解码** | 基于置信度累积的推测解码 |
| **多对话并行** | `--parallel N` 支持同时处理多个对话 |
| **视觉塔** | 多模态输入支持 (`ds4_vision.cu`) |
| **PCIe 流式传输** | 不适合 VRAM 的 expert 通过 PCIe 传输 |

核心文件：
- `src/dsv41/ds4_main.cpp` — 引擎入口（stdin/stdout 协议）
- `src/dsv41/ds4_model.hpp/cu` — 模型抽象（draft, verify, step）
- `src/dsv41/ds4_kernels.cu/cuh` — GPU kernel
- `src/dsv41/ds4_pcie.cuh` — PCIe expert 流式传输
- `src/dsv41/ds4_pool.hpp` — Expert 内存池管理

---

## 五、多平台后端支持

### 5.1 后端矩阵

| 后端 | 硬件 | 状态 | 要求 |
|------|------|------|------|
| **CUDA 13** | NVIDIA sm_75-120 (Turing→Blackwell) | 生产就绪 | CMake 3.24+, CUDA 13 |
| **CUDA 12** | NVIDIA sm_60-89 (Pascal→Ada) | 生产就绪 | CUDA 12 |
| **HIP** | AMD RDNA2/3/4 (RX 6000/7000/9000) | 生产就绪 | ROCm 7.2+ |
| **SYCL** | Intel Arc (A750, Battlemage) | 实验性 | oneAPI 2026.1+ |
| **Metal** | Apple Silicon (M1/M2/M3/M4) | 生产就绪 | macOS, Xcode |
| **CPU** | x86_64 (AVX2 baseline) | 支持 | 无 GPU |
| **DGX Spark** | NVIDIA GB10 (ARM64 CUDA, sm_121) | 生产就绪 | CUDA 13 |
| **Strix Halo** | AMD Ryzen AI Max | 支持 | HIP |

### 5.2 支持的 GPU 列表

**NVIDIA GPU**：
- GeForce RTX 50 系列 (sm_120, Blackwell)
- GeForce RTX 40 系列 (sm_89, Ada)
- GeForce RTX 30 系列 (sm_86, Ampere)
- GeForce RTX 20 系列 (sm_75, Turing)

**AMD GPU**：
- Radeon RX 9060/9070 (RDNA 4)
- Radeon RX 7700/7800/7900 (RDNA 3)
- Radeon RX 6800/6900 (RDNA 2, 实验性 gfx1030)
- AI PRO R9700
- Strix Halo (RX 8060S)

**Intel GPU**：
- Arc A750 (实验性)

**Apple Silicon**：
- M1/M2/M3/M4 全系列

### 5.3 Metal 后端 (`metal/`)

- 独立 CMake 项目，macOS only
- MSL kernel 在 `metal/kernels/*.metal`（运行时编译，30 个 shader 文件）
- 使用 metal-cpp 设备运行时
- 通过兼容头文件共享 `src/` 的主机源码

### 5.4 SYCL 后端 (`sycl/`)

- 独立 CMake 项目，使用 `icpx` 编译器
- 支持 SPIR-V JIT 或 AOT 编译
- 源码迁移：`src/X.cu` → `sycl/src/X.dp.cpp`（通过 `sycl/tools/migrate.sh`）
- 支持 XMX（Xe Matrix Extensions）和 ESIMD kernel
- 使用 oneMKL

### 5.5 HIP 后端

- 两种路径：
  - `STRATA_ENABLE_HIP`：wave32 RDNA GPU（gfx1100, gfx1201）
  - `STRATA_HIP_GFX906`：wave64 MI50 兼容层
- gfx1030 实验性支持
- 使用 `include/strata/hip_compat/` 共享 CUDA/HIP 代码
- Code object 首次使用时加载（不同于 CUDA 的即时加载）

---

## 六、API 服务器 (`serve/`)

### 6.1 兼容接口

提供 **OpenAI** 和 **Anthropic** 兼容的 API 端点：

```
POST /v1/chat/completions  — OpenAI 格式（流式 + 非流式）
POST /v1/messages          — Anthropic 格式（流式 + 非流式）
POST /v1/images/generations — OpenAI 图像生成
GET  /v1/models            — 模型列表
GET  /health               — 健康检查
GET  /slots                — 对话槽位状态
GET  /mcp                  — MCP 协议支持
```

### 6.2 核心组件

| 文件 | 功能 |
|------|------|
| `server.py` | 主服务器入口 |
| `frontend.py` | Chat 模板解析、消息格式转换 |
| `mcp.py` | MCP (Model Context Protocol) 集成 |
| `images.py` | Stable Diffusion 图像生成 |
| `ds_pictures.py` | DeepSeek 视觉/多模态处理 |
| `structured.py` | JSON/结构化输出强制 |
| `logit_bias.py` | Token bias API |
| `telemetry.py` | 性能遥测 |
| `lifeline.py` | 进程健康监控 |

---

## 七、CLI 工具 (`strata_cli/`)

### 7.1 子命令

```bash
strata serve      # 启动推理服务器
strata launch     # 交互式模型设置和启动
strata connect    # 显示连接工具的配置（Claude Code, Codex CLI 等）
strata monitor    # 实时终端仪表板
strata bench      # 性能基准测试
strata tune       # 性能调优
strata profile    # 管理保存的配置
strata doctor     # 诊断检查
strata update     # 自更新
```

### 7.2 关键模块

- `launch/` — 交互式设置向导（模型选择、下载、引擎配置）
- `monitor.py` + `dashboard.py` — 终端监控 UI
- `client.py` — HTTP 客户端
- `handover.py` — 更新交接机制

---

## 八、构建系统

### 8.1 CMake 构建（C++ 引擎）

**基本要求**：
- CMake 3.24+
- C++20 标准
- CUDA 需要 sm_80+（Ampere 或更新）

**关键构建选项**：

| 选项 | 说明 |
|------|------|
| `STRATA_ENABLE_CUDA` | 启用 NVIDIA CUDA 后端 |
| `STRATA_ENABLE_HIP` | 启用 AMD HIP 后端 |
| `STRATA_PORTABLE` | AVX2 baseline + 静态 MSVC 运行时（跨 PC 分发） |
| `STRATA_NATIVE_EXPERTS` | IQ (i-quant) expert 支持 |
| `STRATA_MMQ_KQUANTS` | MMQ prompt kernel（Q4_K/Q5_K/Q6_K） |
| `STRATA_BUILD_SPLIT` | 层分割引擎（2-4 NVIDIA 卡） |
| `STRATA_WINDOW_MAX_T` | 验证/batch 窗口行数（8/12/16） |
| `STRATA_BUILD_TESTS` | 完整测试套件 |

**CMake Presets**：

```json
cpu-check          — 快速 CPU-only 检查，无需 GPU
cpu-check-native   — CPU 检查 + IQ expert 测试
cuda-compile       — CUDA release 编译
hip-compile        — HIP 编译（gfx1100/gfx1201）
```

### 8.2 Python 安装 (`setup.py`)

728KB 的一键安装脚本，功能包括：
- 从 Hugging Face / ModelScope 下载 GGUF 模型（固定 SHA-256 和 commit）
- 下载预构建引擎包或从源码编译
- 硬件自动检测（NVIDIA/AMD GPU、驱动、RAM、CPU、磁盘）
- 安装模式：完整设置、`--setup` 更改配置、`--update` 更新

### 8.3 Python 依赖

| 文件 | 用途 | 关键包 |
|------|------|--------|
| `requirements.txt` | 运行时 | numpy, jinja2, regex, pyyaml, tqdm, requests, pillow, psutil |
| `requirements-build.txt` | 构建 | cmake==4.4.3, ninja==1.13.2 |
| `requirements-dev.txt` | 开发 | pytest==9.1.1, textual==8.2.8 |
| `requirements-monitor.txt` | 监控 | 专用监控依赖 |

---

## 九、容器化部署

### 9.1 两套 Dockerfile

| 文件 | 用途 |
|------|------|
| 根 `Dockerfile` | 从源码构建，CUDA 13，多阶段构建 |
| `docker/Dockerfile` | 生产镜像，使用预构建引擎包，三种 flavor（cuda/hip/sycl） |

### 9.2 Docker 基础设施

```
docker/
├── Dockerfile           # 生产镜像（135 行）
├── entrypoint.sh        # 容器入口（400+ 行：模型下载、preset 管理）
├── build.sh             # 构建脚本
├── publish.sh           # 推送到 ghcr.io
├── fetch-engines.py     # 引擎包下载（Ed25519 签名验证）
├── healthcheck.sh       # 健康检查
├── smoke-test.sh        # 冒烟测试
└── compose/             # Docker Compose 配置
```

### 9.3 根 Dockerfile 构建流程

```
1. engine-build 阶段
   └── Ninja 编译引擎（CUDA arch: 75;80;86;89;120）
   └── 构建 strata + strata_kq + strata-vision

2. terminal 阶段
   └── 构建 Terminal release 归档（捆绑 Python 3.12）

3. runtime 阶段
   └── Ubuntu 24.04 基础 + tini
   └── 健康检查，暴露端口 8080
```

---

## 十、打包与分发

### 10.1 打包工具集

| 工具 | 功能 |
|------|------|
| `package_engine.py` | 创建引擎组件包（manifest + SHA-256 + 架构标签） |
| `package_terminal.py` | 构建 Terminal 归档（捆绑 CPython 3.12.15） |
| `feed_tool.py` | 构建并签名更新 feed（`strata-feed.json`） |
| `collect_libs.py` | 收集 Linux 库依赖（ldd 闭包） |
| `lock_wheels.py` | 创建 hash-locked wheel 依赖 |

### 10.2 目标平台矩阵

| 目标 | 后端 | 状态 |
|------|------|------|
| macOS ARM64 | Metal | ✅ 构建通过，自测通过 |
| Windows x86_64 | CUDA 13, CUDA 12 | ✅ 构建并测试 |
| Windows x86_64 | HIP (Strix Halo) | ✅ 已发布 |
| Linux x86_64 | CUDA 13, CUDA 12 | ✅ 构建并测试 |
| Linux x86_64 | HIP (rx9070/7900/6000) | ✅ 构建，不同测试级别 |
| Linux x86_64 | SYCL (Intel Arc) | ✅ 构建并在 A750 测试 |
| Linux ARM64 | CUDA 13 (DGX Spark) | ✅ 构建并测试 |

### 10.3 安全机制

- **SHA-256 哈希**：每个文件都有固定哈希
- **Ed25519 签名**：更新 feed 和包签名验证
- **固定依赖**：所有 HuggingFace 文件有固定 SHA-256 和 revision
- **无自动下载**：服务期间不自动下载（`STRATA_NO_ACQUIRE`）

---

## 十一、CI/CD 流水线

### 11.1 GitHub Actions 工作流（12 个）

| 工作流 | 功能 |
|--------|------|
| `check.yml` | 快速检查（Linux + Windows），CPU CMake preset，Python 测试 |
| `backends.yml` | 后端编译检查（无 GPU），CUDA 12.9/13.0, HIP ROCm 7.2, SYCL, Metal |
| `docker-images.yml` | 构建并推送容器镜像到 ghcr.io |
| `metal-build.yml` | macOS Metal 引擎构建 |
| `docs.yml` | 文档构建 |
| `title-area.yml` | PR 标题前缀强制（[Engine], [GUI], [TUI] 等） |
| `intake.yml` | 接入检查 |
| `snapshot.yml` | 快照 |
| `scripts-test.yml` | 脚本测试 |

### 11.2 测试策略

| 层级 | 类型 | 说明 |
|------|------|------|
| CPU 测试 | 单元/集成 | 无需 GPU，快速验证 |
| GPU 对等测试 | 回归 | 与 ggml 参考逐位对比 |
| 冒烟测试 | 完整性 | Terminal 归档验证 |
| 后端 CI | 编译 | 所有后端的编译检查 |

---

## 十二、核心技术特性

### 12.1 推测解码

两种 drafting 策略由 `Controller` 管理：

| 策略 | 机制 |
|------|------|
| **Suffix lookup** | 从对话历史进行 N-gram 匹配 |
| **MTP (Multi-Token Prediction)** | 模型自身的 draft head |

控制器使用 EMA 接受率和成本模型决定是否值得 drafting（最低 5% 增益）。

### 12.2 关键技术亮点

| # | 技术 | 说明 |
|---|------|------|
| 1 | **Doorbell 协议** | 映射 pinned 内存实现 CPU expert pool 与 GPU 层执行重叠 |
| 2 | **CUDA Graph 捕获** | 按层 graph，~2000 kernel launch → 48 graph launch |
| 3 | **弹性 KV Cache** | VMM 虚拟内存映射，上下文动态增长 |
| 4 | **KV 流式传输** | 分页 KV cache + 主机常驻溢出（长上下文） |
| 5 | **Expert 缓存** | VRAM 常驻 expert slot + LRU 驱逐（MoE 模型） |
| 6 | **对话 Slot** | 跨请求保存/恢复完整对话状态（DeepSeek） |
| 7 | **DSpark** | 置信度累积推测解码 |
| 8 | **GDN** | 高效线性注意力（delta-rule 递推） |
| 9 | **QSA + Block Indexer** | 稀疏注意力，选择 top-k block |
| 10 | **融合 Gated Residual** | 低秩超连接减少残差堆叠开销 |

---

## 十三、文档体系

| 文档 | 大小 | 内容 |
|------|------|------|
| `docs/DETAILS.md` | 174KB | 完整引擎技术文档 |
| `docs/AMD_HIP.md` | 62KB | AMD GPU 构建和验证 |
| `docs/BATCHING.md` | 63KB | Batching 协议 |
| `docs/DOCKER.md` | 28KB | Docker 部署指南 |
| `docs/BENCHMARK_PROTOCOL.md` | 41KB | 标准基准测试协议 |
| `docs/DEEPSEEK41.md` | 26KB | DeepSeek V4.1 文档 |
| `docs/INTEL.md` | 42KB | Intel GPU 支持 |
| `docs/MAC.md` | 24KB | macOS Metal 文档 |
| `docs/MULTI_GPU.md` | - | 多 GPU 配置 |
| `docs/paper/` | - | Strata 研究论文 (PDF) |

---

## 十四、第三方依赖

| 依赖 | 说明 |
|------|------|
| `strata-ggml/` | 分叉/修改的 GGML 库（张量计算、量化、CUDA/HIP 后端） |
| `ggml/` | 上游 GGML 参考文件 |
| `sfnx/` | 支持库 |
| `project-maya/` | 上游 Maya 项目 (v1.1.17)，DeepSeek 引擎从此移植 |
| `antirez-ds4/` | Antirez 的 DeepSeek 参考实现 |
| `libstrix/` | AMD Strix Halo 支持库 |

---

## 十五、总结与评价

### 优势

1. **完整的端到端系统**：从 C++ 推理引擎到桌面应用到 CLI，覆盖完整使用场景
2. **多平台支持**：NVIDIA/AMD/Intel/Apple GPU 全覆盖，CPU 兜底
3. **创新架构**：Doorbell 协议解决 MoE 大模型 VRAM 限制
4. **生产就绪**：完善的打包、签名、更新机制
5. **API 兼容性**：OpenAI + Anthropic 接口，便于集成
6. **可复现性**：所有依赖固定 SHA-256，模型文件有 commit hash

### 适用场景

- 本地部署 LLM 服务（私有化推理）
- 消费级 GPU 运行大模型（通过 expert 流式加载）
- 多 GPU 推理（层分割模式）
- 需要 OpenAI/Anthropic 兼容 API 的应用

### 技术门槛

- 构建需要 CMake 3.24+, C++20 编译器
- GPU 后端需要对应 SDK（CUDA, ROCm, oneAPI, Xcode）
- 最低 NVIDIA Ampere 架构（sm_80+）用于 CUDA 后端
- 大模型需要充足存储空间（模型文件 + expert 缓存）

---

## 十六、工具集成

### 16.1 支持的 AI 编码工具

通过 OpenAI/Anthropic 兼容 API，Strata 可与以下工具集成：

| 工具 | 集成方式 |
|------|----------|
| **Claude Code** | `strata connect` 显示配置说明 |
| **Codex CLI** | OpenAI API 兼容 |
| **OpenCode** | OpenAI API 兼容 |
| **oh-my-pi** | API 集成 |
| **Hermes Agent** | API 集成 |
| **OpenClaw** | API 集成 |
| **任何 OpenAI/Anthropic 工具** | 直接兼容 |

### 16.2 MCP (Model Context Protocol) 支持

- 内置 MCP 服务器（`serve/mcp.py`）
- 支持工具调用和上下文管理
- 可通过 `GET /mcp` 端点访问

---

## 十七、项目规模统计

| 指标 | 数量 |
|------|------|
| C++/CUDA/Metal/SYCL 源文件 | ~795 |
| 头文件 (`include/strata/`) | 74 |
| Python 模块 (`strata_control/`) | ~100 |
| 服务器测试 (`serve/`) | 100+ |
| 设置测试 (`tools/`) | 60+ |
| 文档文件 (`docs/`) | 80+ |
| `setup.py` 代码行数 | 11,510 |
| `CMakeLists.txt` 代码行数 | ~1,200 |
| Metal shader 文件 | 30 |
| 支持后端数 | 5 (CUDA, HIP, SYCL, Metal, CPU) |
| 支持平台 | 3 (Windows, Linux, macOS) |
| 支持架构 | 2 (x86_64, ARM64) |

---

## 十八、Docker 镜像

**预构建镜像**：`ghcr.io/niko1221/strata`

```bash
# NVIDIA GPU
docker compose -f docker/compose/docker-compose.nvidia.yml up

# AMD GPU  
docker compose -f docker/compose/docker-compose.amd.yml up

# Intel GPU
docker compose -f docker/compose/docker-compose.intel.yml up
```

**环境变量**：
- `MODEL` — 模型选择
- `CONTEXT` — 上下文长度
- `PARALLEL` — 并行对话数
- `VISION` — 视觉能力开关
- `API_KEY` — API 密钥

---

*本报告基于 Strata 项目源代码静态分析生成，未进行运行时测试。*
