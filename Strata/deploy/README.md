# Strata 部署方案

> 基于 Strata v0.2.13 (引擎 v0.1.59)
> 官方仓库: https://github.com/Niko1221/Strata

---

## 目录

- [硬件配置](#硬件配置)
- [推荐模型](#推荐模型)
- [安装部署](#安装部署)
- [API 服务](#api-服务)
- [工具集成](#工具集成)
- [参考链接](#参考链接)

---

## 硬件配置

### 本机环境

| 组件 | 规格 |
|------|------|
| **GPU** | NVIDIA GeForce RTX 3090 (24GB VRAM) |
| **CUDA** | 13.2 |
| **驱动** | 595.99.02 (≥580 支持 CUDA 13) ✅ |
| **CPU** | Intel Xeon E5-2680 v4 @ 2.40GHz |
| **内存** | 32GB |
| **磁盘** | `/home` 1.1GB ⚠️ \| `/data` 56GB ✅ |

### 支持的硬件

| 硬件 | 指南 |
|------|------|
| **NVIDIA GeForce RTX 20 / 30 / 40 / 50 系列** | [NVIDIA 设置](https://github.com/Niko1221/Strata/blob/main/docs/INSTALL.md#what-you-need) |
| **AMD Radeon RX 7700 / 7800 / 7900, RX 9060 / 9070, AI PRO R9700** | [AMD 设置](https://github.com/Niko1221/Strata/blob/main/docs/AMD_HIP.md) |
| **AMD Radeon RX 6800 / 6900 · 实验性** | [RX 6000 设置](https://github.com/Niko1221/Strata/blob/main/docs/AMD_HIP.md#rdna2-gfx1030) |
| **Intel Arc · Linux** | [Intel 设置](https://github.com/Niko1221/Strata/blob/main/docs/INTEL_ARC.md) |
| **Apple Silicon · M1 或更新** | [Mac 设置](https://github.com/Niko1221/Strata/blob/main/docs/MAC.md) |
| **AMD Ryzen AI Max · Strix Halo** | [Strix Halo 设置](https://github.com/Niko1221/Strata/blob/main/docs/STRIX_HALO.md) |
| **NVIDIA DGX Spark · Linux** | [DGX Spark 设置](https://github.com/Niko1221/Strata/blob/main/docs/DGX_SPARK_LINUX.md) |

---

## 推荐模型

> 推荐顺序: **ISTA-DASLab → Unsloth → Gyro → 其他**

### Qwen3.8-Flash-Next (推荐)

#### ISTA-DASLab 原版模型

| 模型 | 内存需求 (RAM+VRAM) | Shard 1 大小 | 速度 | 质量 | 命令 |
|------|---------------------|--------------|------|------|------|
| **Q2_0** | 37.6 GB | 34 GB | 最快 | good | `--family qwen --model q2_0` |
| **IQ2_XS** | 39.2 GB | 35.5 GB | 快 | better | `--family qwen --model iq2_xs` |
| **IQ3_XXS** | 47.0 GB | 43 GB | 较慢 | great | `--family qwen --model iq3_xxs` |
| **IQ3_S** | 54.8 GB | 50 GB | 最慢 | best | `--family qwen --model iq3_s` |
| **Coder (IQ1_M)** | ~32 GB | 23 GB | 快 | 编程专用 | `--family coder --model IQ1_M` |

#### 其他提供商

| 提供商 | 选项 | 说明 |
|--------|------|------|
| **Unsloth** | UD-IQ4_XS, UD-Q4_K_XL, UD-Q5_K_XL, UD-Q6_K_XL, Q8_0 | 4-8 bit 量化，需 72-136 GB RAM |
| **Gyro · agentionai** | Gyro-S, Gyro-M | 低内存, 较慢 |
| **其他** | Swift 1.5, NVFP4, OrcaRouter | 微调或特殊格式 |

#### 本机适配分析 (RTX 3090 24GB + 32GB RAM)

| 模型 | 能否部署 | 运行模式 | 说明 |
|------|----------|----------|------|
| **Coder IQ1_M** | ✅ 可以 | 正常模式 | 23GB experts，GPU 可容纳大部分 |
| **Q2_0** | ⚠️ 可以 | low-ram 模式 | 34GB experts，需要 SSD 辅助读取 |
| **IQ2_XS** | ⚠️ 可以 | low-ram 模式 | 35.5GB experts，需要 SSD 辅助读取 |
| **IQ3_XXS** | ❌ 不建议 | - | 43GB experts，远超 RAM 容量 |
| **IQ3_S** | ❌ 不建议 | - | 50GB experts，远超 RAM 容量 |

> **low-ram 模式**: 当 RAM 不足以容纳所有 experts 时，Strata 会将 experts 映射到 SSD，GPU VRAM 容纳部分，剩余从 SSD 读取。速度会明显下降，但可以运行。
>
> 官方确认: "A 32 GB PC with a 24 GB GPU runs Q2_0, IQ2_XS and the Coder this way"

#### Coder IQ1_M 详解

**Coder 是基于 Qwen3.8-Flash-Next 的编程优化版本**，由 ISTA-DASLab 制作。

| 属性 | 说明 |
|------|------|
| **基础模型** | Qwen3.8-Flash-Next |
| **HuggingFace** | [Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF](https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF) |
| **量化** | IQ1_M |

**与完整版的区别:**

| 对比项 | 完整版 (512 experts) | Coder 版 (256 experts) |
|--------|---------------------|------------------------|
| **每层专家数** | 512 | 256 (保留一半) |
| **选择依据** | 全部保留 | 基于代码+agent+图片数据筛选 |
| **SWE-bench Verified** | 100% | 91% |
| **LiveCodeBench** | 100% | 99% |
| **内存需求** | 37.6-54.8 GB | ~32 GB |
| **适用场景** | 通用任务 | 编程专用 |

> **注意**: Coder 在非代码任务和英文/中文以外的语言上表现较弱。通用场景请使用完整版 Q2_0 或更高精度。

### Qwen3.6-35B-A3B

MoE 架构，35B 参数，每 token 激活 3B。

**Unsloth:** UD-Q4_K_XL, UD-Q6_K_XL, Q8_0

### DeepSeekV4.1-Flash-1017

| 集合 (ISTA-DAS) | 下载大小 | 所需磁盘 |
|-----------------|----------|----------|
| 1.75 bpw | 239 GB | ~245 GB |
| 2.00 bpw | 257 GB | ~265 GB |
| 2.25 bpw | 274 GB | ~280 GB |
| Coder (专家数减半) | 191 GB | ~197 GB |

### 本机推荐方案

| 优先级 | 模型 | 理由 | 命令 |
|--------|------|------|------|
| ⭐⭐⭐ | **Coder IQ1_M** | 编程优化, 内存友好 | `--family coder --model IQ1_M` |
| ⭐⭐ | **Qwen Q2_0** | 通用模型, 支持图片 | `--family qwen --model q2_0` |
| ⭐ | **Qwen IQ2_XS** | 质量更好, 需要更多内存 | `--family qwen --model iq2_xs` |

---

## 安装部署

### 1. 安装 Strata Terminal

**Linux / Mac:**

```bash
curl -fsSL --connect-timeout 15 --max-time 120 \
  https://github.com/Niko1221/Strata/releases/latest/download/install.sh \
  -o install.sh && sh install.sh
```

**Windows PowerShell:**

```powershell
irm -TimeoutSec 120 https://github.com/Niko1221/Strata/releases/latest/download/install.ps1 | iex
```

### 2. 配置存储路径

由于 `/home` 分区空间不足，使用 `/data` 存储模型:

```bash
# 创建目录
mkdir -p /data/strata-models /data/.strata

# 设置环境变量
export STRATA_HOME=/data/.strata
```

### 3. 预览部署计划

```bash
# 查看计划，不做任何更改
strata launch --plan --family coder --model IQ1_M
```

### 4. 启动模型

```bash
# 编程模型 (推荐)
strata launch --family coder --model IQ1_M \
  --data-dir /data/strata-models \
  --yes --no-tui

# 或通用模型
strata launch --family qwen --model q2_0 \
  --data-dir /data/strata-models \
  --yes --no-tui
```

### 常用启动参数

| 参数 | 说明 |
|------|------|
| `--family qwen\|coder\|unsloth\|gyro\|deepseek41\|qwen36` | 模型系列 |
| `--model NAME` | 模型名称 |
| `--data-dir DIR` | 模型存储目录 |
| `--context 32k\|64k\|128k` | 上下文长度 |
| `--vision off\|on\|gpu\|cpu` | 图片处理能力 |
| `--parallel N` | 并行请求数 |
| `--port PORT` | 服务端口 |
| `--access local\|lan\|cloudflare\|tailscale` | 访问模式 |
| `--api-key-env NAME` | API 密钥环境变量 |
| `--speed faster\|full` | DeepSeek 速度模式 |
| `--model-path DIR` | 使用已有模型文件 |

---

## API 服务

### 端点

启动后默认端点: `http://127.0.0.1:8080`

| 接口 | 端点 | 说明 |
|------|------|------|
| **OpenAI 兼容** | `/v1/chat/completions` | ChatGPT 格式 |
| **Anthropic 兼容** | `/v1/messages` | Claude 格式 |
| **图像生成** | `/v1/images/generations` | Stable Diffusion |
| **模型列表** | `/v1/models` | 可用模型 |
| **健康检查** | `/health` | 服务状态 |
| **MCP 协议** | `/mcp` | Model Context Protocol |

### 测试 API

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "strata",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 100
  }'
```

---

## 工具集成

Strata 支持通过 OpenAI 和 Anthropic 兼容 API 与以下工具集成:

**Claude Code · Codex CLI · OpenCode · oh-my-pi · pi.dev · Hermes Agent · OpenClaw**

### 查看连接说明

```bash
strata connect
```

### Claude Code

```bash
export ANTHROPIC_BASE_URL=http://127.0.0.1:8080
claude
```

### Codex CLI / OpenAI 工具

```bash
export OPENAI_BASE_URL=http://127.0.0.1:8080/v1
export OPENAI_API_KEY=dummy  # 本地不需要真实 key
```

### 检查连接

```bash
strata connect <app> --check  # 发送测试请求
```

---

## 管理命令

```bash
# 查看运行状态
strata launch --status

# 停止模型
strata launch --stop

# 查看已安装模型
strata models list

# 显示 API 密钥
strata launch --show-key

# 更新 Strata
strata update --check
strata update

# 查看版本
strata --version
```

---

## systemd 服务

使用提供的 `strata.service` 文件实现后台持久运行:

```bash
# 安装服务
sudo cp strata.service /etc/systemd/system/
sudo systemctl daemon-reload

# 启动服务
sudo systemctl enable --now strata

# 查看日志
journalctl -u strata -f
```

---

## 参考链接

| 资源 | 链接 |
|------|------|
| **官方仓库** | https://github.com/Niko1221/Strata |
| **最新版本** | https://github.com/Niko1221/Strata/releases/latest |
| **完整文档** | https://github.com/Niko1221/Strata/tree/main/docs |
| **模型详情** | [docs/MODELS.md](https://github.com/Niko1221/Strata/blob/main/docs/MODELS.md) |
| **安装指南** | [docs/INSTALL.md](https://github.com/Niko1221/Strata/blob/main/docs/INSTALL.md) |
| **终端指南** | [docs/TERMINAL_LAUNCH.md](https://github.com/Niko1221/Strata/blob/main/docs/TERMINAL_LAUNCH.md) |
| **技术细节** | [docs/DETAILS.md](https://github.com/Niko1221/Strata/blob/main/docs/DETAILS.md) |
| **故障排除** | [docs/TROUBLESHOOTING.md](https://github.com/Niko1221/Strata/blob/main/docs/TROUBLESHOOTING.md) |

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `README.md` | 本部署方案文档 |
| `setup.sh` | 一键部署脚本 |
| `strata.service` | systemd 服务配置 |
| `QUICK-REFERENCE.md` | 快速参考卡 |

---

*基于 Strata v0.2.13 官方文档编写，MIT License*
