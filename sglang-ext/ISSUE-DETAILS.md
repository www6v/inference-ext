# Issue 详细分析：#42917 和 #42508

---

## 📋 Issue #42917: Qwen3.8-27B 量化质量下降

### 基本信息

| 字段 | 值 |
|------|-----|
| **标题** | [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4, symmetric, group 128) serves with degraded quality |
| **作者** | @jolpindo96 |
| **创建** | 2026-10-07 |
| **更新** | 2026-10-10 |
| **评论** | 2 |
| **链接** | https://github.com/sgl-project/sglang/issues/42917 |

### 问题描述

**模型**: `dbirks/Qwen3.8-27B-W4A16-AutoRound`
- 量化方式: W4A16 (INT4, symmetric, group 128)
- 配置: compressed-tensors pack-quantized
- 未量化模块: 215 个 (vision tower, linear_attn, lm_head, MTP layers)

**症状**:
- SGLang 加载无错误，但输出质量严重下降
- vLLM 使用相同 checkpoint 输出正常

**性能对比**:

| 引擎 | PPL | KLD | Top-1 一致性 |
|------|-----|-----|-------------|
| SGLang 0.5.19 | 9.6276 | - | 70.2% |
| SGLang 0.5.20 | 9.7036 | 0.554 | 69.8% |
| SGLang 0.5.21 | 9.9767 | 0.590 | 69.1% |
| **vLLM 0.30.0** | **6.0528** | **0.042** | **92.9%** |
| 参考 (llama.cpp Q8_0) | 6.0539 | - | - |

**关键观察**:
- PPL 从 6.05 恶化到 9.98 (下降 65%)
- Top-1 一致性只有 69% (vs vLLM 的 93%)
- SGLang 0.5.20 和 0.5.21 之间也有差异 (KL 0.42)
- 这表明是**结构性错误**，不是精度问题

**已排除的原因**:
- ✅ `in_proj_ba` 融合正确 (bf16 gating projections 应该正确加载)
- ✅ 测试 harness 稳定 (NVFP4 checkpoint 结果一致)

**怀疑的原因**:
1. 加载 packed INT4 `in_proj_qkv` 到 fused `in_proj_qkvz` (stacked mapping)
2. symmetric group-128 WNA16 kernel 路径

### 复现方法

```bash
docker run --gpus all --ipc=host -p 30000:30000 -v hf-cache:/root/.cache lmsysorg/sglang:v0.5.21-cu130 \
  python3 -m sglang.launch_server \
  --model-path dbirks/Qwen3.8-27B-W4A16-AutoRound \
  --kv-cache-dtype bfloat16 \
  --context-length 4096 \
  --mem-fraction-static 0.70 \
  --disable-radix-cache \
  --trust-remote-code \
  --max-running-requests 4 \
  --cuda-graph-max-bs-decode 4 \
  --host 0.0.0.0 --port 30000
```

测试: 发送 wikitext-2 的 2048 token chunks，测量 logprobs

### 环境

- **GPU**: RTX 5090 (32GB, SM120)
- **CUDA**: 13.0
- **PyTorch**: 2.13.0+cu130
- **SGLang**: 0.5.21

### 3090 可复现性分析

**✅ 可以在 3090 上复现**

理由:
1. **模型大小**: Qwen3.8-27B-W4A16 (INT4 量化)
   - 原始 27B 参数 × 4 bits = ~13.5 GB
   - 加上 KV cache 和 overhead ≈ 18-20 GB
   - **可以在 24GB 内运行** ✅

2. **量化支持**: INT4/W4A16
   - 3090 (Ampere SM86) 完全支持 INT4 量化 ✅
   - 不需要 Blackwell 特性

3. **问题本质**: 量化权重加载/计算错误
   - 纯软件 bug，与硬件架构无关 ✅

**建议复现步骤**:
```bash
# 在 3090 上
docker run --gpus all --ipc=host -p 30000:30000 \
  -v hf-cache:/root/.cache lmsysorg/sglang:v0.5.21-cu130 \
  python3 -m sglang.launch_server \
  --model-path dbirks/Qwen3.8-27B-W4A16-AutoRound \
  --kv-cache-dtype bfloat16 \
  --context-length 2048 \
  --mem-fraction-static 0.80 \
  --trust-remote-code
```

然后测试几个 prompt，比较输出质量。

**难度**: 🟡 中等
- 需要理解量化权重加载流程
- 需要对比 SGLang 和 vLLM 的实现差异
- 可能需要调试 kernel 代码

---

## 📋 Issue #42508: Scheduler 内存损坏崩溃

### 基本信息

| 字段 | 值 |
|------|-----|
| **标题** | [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check |
| **作者** | @LUOSENGWA |
| **创建** | 2026-10-04 |
| **更新** | 2026-10-05 |
| **评论** | 2 |
| **链接** | https://github.com/sgl-project/sglang/issues/42508 |

### 问题描述

**症状**:
- 运行 ~22 小时后，scheduler 进程崩溃
- 错误: `double free or corruption (out)` (glibc 检测到堆损坏)
- 崩溃后服务器永久挂起 (不响应任何请求)
- 需要手动重启容器

**崩溃堆栈**:
```
double free or corruption (out)
Fatal Python error: Aborted

Current thread:
  File "sglang/srt/session/streaming_session.py", line 424 in session_held_tokens
  File "sglang/srt/mem_cache/unified_radix_cache.py", line 3543 in session_held_tokens
  File "sglang/srt/managers/scheduler_components/pool_stats_observer.py", line 184
  File "sglang/srt/managers/scheduler_components/invariant_checker.py", line 113
  File "sglang/srt/managers/scheduler_components/invariant_checker.py", line 507
  File "sglang/srt/managers/scheduler.py", line 4969 in on_idle
  File "sglang/srt/managers/scheduler.py", line 2003 in event_loop_overlap
```

**崩溃路径**:
`on_idle()` → `_check_all_pools()` → `_check_full_pool()` → `session_held_tokens()` → 崩溃

**崩溃后行为**:
- `/health` 报告: "couldn't get response from detokenizer for 20 seconds"
- `/v1/models` 和 `/metrics` 返回 200 但计数器冻结
- 所有生成请求接受连接但永不返回
- 进程仍在运行但 CPU 时间停止增长 (wedged)
- 2 小时后仍需手动重启

### 环境

- **GPU**: 1× RTX PRO 5000 72GB (SM120)
- **模型**: Qwen3.5-27B-FP8 (hybrid GDN-Mamba + MTP/EAGLE)
- **配置**:
  - `context_length=262144` (262k tokens)
  - `kv_cache_dtype=fp8_e4m3`
  - `mem_fraction_static=0.9`
  - `speculative_algorithm=EAGLE`
  - `max_mamba_cache_size=32`
  - `enable_streaming_session=False`
- **服务场景**: 24 个 agent，混合短对话 + 长会话 (~100-140k tokens)
- **运行时间**: 崩溃前运行 22h24m

### 根本原因分析

**问题**: 堆损坏 (heap corruption)
- glibc 检测到 `double free or corruption`
- 发生在 idle 检查期间 (只读操作 + 分配)
- 最可能是 session/mamba/KV 释放路径中的 free/ownership bug

**相关 issue**:
- #26482 / #22511 / #10856 / #11925 — 崩溃后症状类似，但没有崩溃堆栈
- #40250 / #40252 (已合并) — session/mamba 释放路径修复
- #41617 — radix-cache free/ownership bug
- **结论**: 可能是同一类问题，但触发条件不同

### 3090 可复现性分析

**⚠️ 可能可以，但有挑战**

**挑战**:
1. **原始环境**: 72GB GPU + 262k context
   - 3090 只有 24GB
   - 262k context 需要巨大 KV cache

2. **触发条件**: 运行 22 小时后
   - 需要长时间稳定性测试
   - 可能需要特定的负载模式

**可行的复现策略**:

1. **缩小模型**: 使用 Qwen3.5-7B-FP8 或更小的模型
2. **缩短 context**: 使用 4k-8k context 而不是 262k
3. **加速触发**: 
   - 增加请求并发
   - 使用 streaming session
   - 频繁创建/销毁 session

**建议测试配置**:
```bash
# 在 3090 上
docker run --gpus all --ipc=host -p 30000:30000 \
  lmsysorg/sglang:nightly-dev-20261003-65f75914 \
  python3 -m sglang.launch_server \
  --model-path Qwen/Qwen3.5-7B-FP8 \
  --context-length 8192 \
  --mem-fraction-static 0.85 \
  --speculative-algorithm EAGLE \
  --max-running-requests 32 \
  --enable-streaming-session
```

然后运行负载测试 12-24 小时，观察是否出现崩溃。

**难度**: 🔴 困难
- 内存管理 bug 通常需要深入理解代码
- 需要复现特定的触发条件
- 可能需要添加调试日志或 memory sanitizer

---

## 📊 对比总结

| Issue | 问题类型 | 3090 可复现 | 难度 | 优先级 |
|-------|---------|------------|------|--------|
| #42917 | 量化质量下降 | ✅ 可以 | 🟡 中等 | ⭐⭐⭐ |
| #42508 | 内存损坏崩溃 | ⚠️ 需调整 | 🔴 困难 | ⭐⭐ |

### 建议

1. **#42917** - 优先处理
   - 可以在 3090 完整复现
   - 影响所有使用 INT4 量化的用户
   - 问题明确，有对比基准 (vLLM)

2. **#42508** - 次优先
   - 需要调整测试参数
   - 是严重的稳定性问题
   - 但触发条件复杂，调试困难

---

*详细分析完成。两个 issue 都有可能在 3090 上复现，但 #42917 更直接。*
