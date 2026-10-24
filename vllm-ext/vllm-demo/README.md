# vLLM Benchmark

GPU 性能基准测试工具，使用 vLLM 推理引擎在本地 GPU 上运行大语言模型推理测试。

## 功能

- **吞吐量测试** - 测量每秒生成的 token 数 (tok/s)
- **延迟测试** - 不同输出长度下的性能表现
- **并发测试** - 多请求并行场景下的性能
- **TTFT 测试** - 首 token 时间 (Time To First Token)

## 环境要求

- Python 3.13+
- NVIDIA GPU (支持 CUDA)
- CUDA 12.1+
- 足够的 GPU 显存 (根据模型大小)

## 安装

```bash
# 创建虚拟环境
python3.13 -m venv .venv
source .venv/bin/activate

# 安装依赖
pip install -e .
```

## 使用方法

### 快速开始

运行默认模型 (Qwen3.5-27B AWQ 量化版) 的基准测试：

```bash
source .venv/bin/activate
python -m vllm_benchmark
```

### 命令行选项

```bash
# 指定模型
python -m vllm_benchmark --model QuantTrio/Qwen3.5-27B-AWQ

# 使用 ModelScope 镜像下载
export HF_ENDPOINT=https://hf-mirror.com
python -m vllm_benchmark --model QuantTrio/Qwen3.5-27B-AWQ

# 指定输出路径保存 JSON 报告
python -m vllm_benchmark --output results/benchmark_report.json

# 调整并发请求数
python -m vllm_benchmark --concurrent 10

# 调整最大生成长度
python -m vllm_benchmark --max-model-len 8192

# 调整 GPU 显存利用率 (24GB GPU 推荐 0.85)
python -m vllm_benchmark --gpu-memory-utilization 0.85
```

### 使用自定义模型

```bash
# 使用 HuggingFace/ModelScope 模型
python -m vllm_benchmark --model QuantTrio/Qwen3.5-27B-AWQ

# 使用本地模型路径
python -m vllm_benchmark --model /path/to/local/model

# 使用量化模型 (推荐)
python -m vllm_benchmark --model QuantTrio/Qwen3.5-27B-AWQ
```

## 测试模型

默认使用 **Qwen3.5-27B-AWQ** (4-bit AWQ 量化)，这是 Qwen3.5 27B 的纯文本 AWQ 量化版本。

### Qwen3.5-27B-AWQ 规格

| 参数 | 值 |
|------|-----|
| 参数量 | ~27B |
| 量化精度 | 4-bit (AWQ) |
| 显存需求 | ~14-16GB |
| 上下文长度 | 4096 (默认) |
| 推荐 GPU | RTX 3090 (24GB) 或更高 |
| 模型类型 | 纯文本 (Text-only) |

## 输出示例

```
=======================================================
  vLLM GPU Benchmark
  Model: Qwen/Qwen3.8B-AWQ
=======================================================
Loading model: Qwen/Qwen3.8B-AWQ
Model loaded successfully

  GPU: NVIDIA GeForce RTX 3090 (24GB)

=== Latency Sweep ===
  max_tokens=32        |   1.25s |   32 tok |   25.6 tok/s | TTFT: 45.2 ms
  max_tokens=128       |   4.89s |  128 tok |   26.2 tok/s | TTFT: 48.1 ms
  max_tokens=512       |  19.45s |  512 tok |   26.3 tok/s | TTFT: 52.3 ms

=== Concurrent Benchmark (5 parallel) ===
  Wall time: 5.12s
  Total: 640 tokens
  Aggregate: 125.0 tok/s
  Per-request avg: 24.8 tok/s

=======================================================
  SUMMARY
=======================================================
  Model: Qwen/Qwen3.8B-AWQ
  GPU: NVIDIA GeForce RTX 3090
  Avg throughput (single): 26.0 tok/s
  Avg TTFT: 48.5 ms
  Concurrent wall time: 5.1s
=======================================================
```

## 项目结构

```
vllm-demo/
├── src/vllm_benchmark/
│   ├── __init__.py      # 包初始化
│   ├── __main__.py      # CLI 入口
│   └── cli.py           # 主程序
├── tests/
│   ├── __init__.py
│   └── test_benchmark.py
├── logs/                 # 日志输出目录
├── results/              # 测试报告输出目录
├── pyproject.toml        # 项目配置
└── README.md             # 本文档
```

## 监控 GPU

运行测试时，可以在另一个终端监控 GPU 使用情况：

```bash
watch -n 1 nvidia-smi
```

## 故障排除

### CUDA out of memory

降低 `--gpu-memory-utilization` 参数：

```bash
python -m vllm_benchmark --gpu-memory-utilization 0.7
```

### 模型下载慢

使用镜像源：

```bash
export HF_ENDPOINT=https://hf-mirror.com
python -m vllm_benchmark
```

## 许可证

MIT License
