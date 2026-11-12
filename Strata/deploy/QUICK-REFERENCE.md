# Strata 快速参考卡

> Strata v0.2.13 (引擎 v0.1.59) | RTX 3090 (24GB) | RAM 32GB | CUDA 13.2

---

## 安装

```bash
# Linux / Mac
curl -fsSL --connect-timeout 15 --max-time 120 \
  https://github.com/Niko1221/Strata/releases/latest/download/install.sh \
  -o install.sh && sh install.sh

# Windows PowerShell
irm -TimeoutSec 120 https://github.com/Niko1221/Strata/releases/latest/download/install.ps1 | iex
```

---

## 启动模型

```bash
# 编程模型 (推荐)
strata launch --family coder --model IQ1_M --data-dir /data/strata-models

# 通用模型
strata launch --family qwen --model q2_0 --data-dir /data/strata-models

# 更高质量
strata launch --family qwen --model iq2_xs --data-dir /data/strata-models

# Qwen3.6 MoE 轻量模型
strata launch --family qwen36 --model UD-Q4_K_XL --data-dir /data/strata-models

# DeepSeek V4.1-Flash (需要大量磁盘)
strata launch --family deepseek41 --model ist-das-2.00bpw --data-dir /data/strata-models

# 交互式选择
strata launch --data-dir /data/strata-models

# 后台运行 (无 TUI)
strata launch --family qwen --model q2_0 --yes --no-tui
```

---

## 模型系列

### ISTA-DASLab Qwen3.8-Flash-Next (完整版 512 experts)

| 模型 | 内存需求 | Shard 1 | 本机适配 | 命令 |
|------|----------|---------|----------|------|
| Q2_0 | 37.6 GB | 34 GB | ⚠️ low-ram | `--family qwen --model q2_0` |
| IQ2_XS | 39.2 GB | 35.5 GB | ⚠️ low-ram | `--family qwen --model iq2_xs` |
| IQ3_XXS | 47.0 GB | 43 GB | ❌ | `--family qwen --model iq3_xxs` |
| IQ3_S | 54.8 GB | 50 GB | ❌ | `--family qwen --model iq3_s` |

### Coder (Qwen3.8-Flash-Next 编程版 256 experts)

| 模型 | 内存需求 | Shard 1 | 本机适配 | 命令 |
|------|----------|---------|----------|------|
| IQ1_M | ~32 GB | 23 GB | ✅ 正常 | `--family coder --model IQ1_M` |

### 其他模型系列

| Family | 说明 | 选项 |
|--------|------|------|
| `unsloth` | Unsloth 量化 (需 72-136 GB RAM) | UD-IQ4_XS, UD-Q4_K_XL, UD-Q5_K_XL, Q8_0 |
| `gyro` | 低内存选项 | Gyro-S, Gyro-M |
| `qwen36` | Qwen3.6-35B-A3B (MoE) | UD-Q4_K_XL, UD-Q6_K_XL, Q8_0 |
| `deepseek41` | DeepSeek V4.1-Flash | ist-das-1.75bpw, ist-das-2.00bpw, ist-das-2.25bpw |
| `swift` | Swift 1.5 微调 | IQ2_XS |
| `nvfp4` | NVIDIA FP4 (需 ~80 GB RAM) | NVFP4, NVFP4-NVIDIA, NVFP4-QAD |

### 本机适配说明 (RTX 3090 24GB + 32GB RAM)

- ✅ **正常模式**: GPU VRAM + RAM 可容纳模型
- ⚠️ **low-ram 模式**: RAM 不足，experts 从 SSD 读取，速度下降
- ❌ **不建议**: 超出硬件能力

> 官方确认: "A 32 GB PC with a 24 GB GPU runs Q2_0, IQ2_XS and the Coder this way"

---

## 管理命令

```bash
strata launch --status          # 查看状态
strata launch --stop            # 停止模型
strata launch --show-key        # 显示 API 密钥
strata models list              # 已安装模型
strata connect                  # 连接说明
strata update --check           # 检查更新
strata update                   # 执行更新
strata --version                # 查看版本
```

---

## API 端点

服务启动后: `http://127.0.0.1:8080`

| 接口 | 端点 |
|------|------|
| OpenAI Chat | `POST /v1/chat/completions` |
| Anthropic | `POST /v1/messages` |
| 图像生成 | `POST /v1/images/generations` |
| 模型列表 | `GET /v1/models` |
| 健康检查 | `GET /health` |
| MCP | `GET /mcp` |

### 测试

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"strata","messages":[{"role":"user","content":"Hello!"}]}'
```

---

## 工具连接

```bash
# 查看配置说明
strata connect

# Claude Code
export ANTHROPIC_BASE_URL=http://127.0.0.1:8080
claude

# Codex CLI / OpenAI 工具
export OPENAI_BASE_URL=http://127.0.0.1:8080/v1
export OPENAI_API_KEY=dummy

# 检查连接
strata connect <app> --check
```

---

## 启动参数

```bash
--family NAME         # 模型系列
--model NAME          # 模型名称
--data-dir DIR        # 模型存储目录
--model-path DIR      # 使用已有模型文件
--context 32k|64k|128k  # 上下文长度
--vision off|on|gpu|cpu # 图片处理
--parallel N          # 并行请求数
--port PORT           # 服务端口 (默认 8080)
--access local|lan|cloudflare|tailscale  # 访问模式
--api-key-env NAME    # API 密钥环境变量
--new-key             # 生成新 API 密钥
--speed faster|full   # DeepSeek 速度 (默认 faster)
--gpu 0,1             # 指定 GPU
--save-preset NAME    # 保存配置
--yes                 # 跳过确认
--no-tui              # 后台运行
--plan                # 仅显示计划
--restart             # 重启模型
```

---

## systemd 服务

```bash
# 安装
sudo cp strata.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now strata

# 管理
sudo systemctl start|stop|restart strata
journalctl -u strata -f
```

---

## 存储位置

| 项目 | 位置 |
|------|------|
| 配置 | `~/.strata` 或 `$STRATA_HOME` |
| 引擎 (Linux) | `~/.local/share/strata/components` |
| 模型 | `--data-dir` 指定或启动时选择 |

---

## 故障排除

| 问题 | 解决方案 |
|------|----------|
| 找不到 strata | `source ~/.bashrc` 或 `~/.local/bin/strata` |
| 磁盘空间不足 | `df -h /data`，清理或扩展 |
| 内存不足 | 使用 Coder 或 Gyro 模型 |
| GPU 未检测到 | `nvidia-smi` 检查驱动 |
| 驱动版本过低 | 需 ≥580 (CUDA 13) |

---

## 参考链接

- 官方仓库: https://github.com/Niko1221/Strata
- 模型详情: https://github.com/Niko1221/Strata/blob/main/docs/MODELS.md
- 安装指南: https://github.com/Niko1221/Strata/blob/main/docs/INSTALL.md
- 终端指南: https://github.com/Niko1221/Strata/blob/main/docs/TERMINAL_LAUNCH.md
- 技术细节: https://github.com/Niko1221/Strata/blob/main/docs/DETAILS.md
