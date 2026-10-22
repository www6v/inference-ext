# SGLang MTP Issues - 3090 GPU 可修复性分析

**分析日期:** 2026-10-14 15:17:01  
**GPU 环境:** NVIDIA RTX 3090 (24GB VRAM, SM86 Ampere)  
**分析范围:** 32 个开放 issue

---

## 📊 总体统计

| 分类 | 数量 | 占比 |
|------|------|------|
| ✅ 可在 3090 修复 | 22 | 69% |
| ❌ 需要特定硬件 | 7 | 22% |
| ⚠️ 需要多 GPU 环境 | 3 | 9% |

### 难度分布 (可在 3090 修复的 22 个)

| 难度 | 数量 | 说明 |
|------|------|------|
| 🟢 简单 | 2 | 逻辑清晰，修复直接 |
| 🟡 中等 | 17 | 需要理解代码逻辑，有明确的问题描述 |
| 🔴 困难 | 3 | 性能优化或复杂架构问题 |

---

## 🟢 简单难度 (2 个)

这些问题逻辑相对清晰，修复方案直接，适合快速解决。


### 1. #33713: unified_cache: MAMBA component nodes are pruned instead of downgraded on device eviction, breaking host-tier loadback

**链接:** [https://github.com/sgl-project/sglang/issues/33713](https://github.com/sgl-project/sglang/issues/33713)  
**评论数:** 3

**问题描述:**
## Symptom

When the unified radix cache evicts a node whose model uses the MAMBA (hybrid-KDA) component, the node is pruned outright from the radix tree instead of being downgraded to host-resident. A subsequent request for the same prefix never even attempts H→D load-back and reports `cached_token...

**修复建议:**
- 可在单卡 3090 上复现和测试
- 问题逻辑相对简单，适合入门

---

### 2. #42217: MultiDetokenizerRouter splits each batch into per-request IPC sends

**链接:** [https://github.com/sgl-project/sglang/issues/42217](https://github.com/sgl-project/sglang/issues/42217)  
**评论数:** 1

**问题描述:**

## Summary

In SGLang 0.5.17, `MultiDetokenizerRouter` receives a batch from the scheduler but forwards a batch request by splitting it into one output message per request. In a multi-tokenizer/multi-detokenizer deployment, this makes the single router perform one serialization and IPC send for eve...

**修复建议:**
- 可在单卡 3090 上复现和测试
- 问题逻辑相对简单，适合入门

---

## 🟡 中等难度 (17 个)

这些问题有明确的错误描述或行为异常，需要理解 SGLang 代码库，但不涉及复杂的性能优化。


### 1. #44145: [Bug][Speculative] EAGLE/MTP causes 90% KV cache starvation on models with untied embeddings (Fix Included)

**链接:** [https://github.com/sgl-project/sglang/issues/44145](https://github.com/sgl-project/sglang/issues/44145)  
**评论数:** 0

**问题描述:**
### Bug Description
When running EAGLE/MTP speculative decoding on models with untied embeddings (`tie_word_embeddings: false`) and large vocabularies (e.g. Qwen 2.5 / Qwen 3.x with vocab 248,320), the draft model allocates its own BF16 `embed_tokens...

---

### 2. #42510: [Bug] EAGLE/MTP same-checkpoint draft keeps redundant embed_tokens/lm_head copies resident during KV pool sizing → under-sized pool, startup OOM

**链接:** [https://github.com/sgl-project/sglang/issues/42510](https://github.com/sgl-project/sglang/issues/42510)  
**评论数:** 1

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this i...

---

### 3. #36669: [Bug] GLM-5.3-Flash thinking output degenerates into repeated '!' under multi-tool agentic prompts

**链接:** [https://github.com/sgl-project/sglang/issues/36669](https://github.com/sgl-project/sglang/issues/36669)  
**评论数:** 4

**问题描述:**
## Summary

When serving zai-org/GLM-5.3-Flash (native FP8 checkpoint) with SGLang, requests with a complex system prompt + multiple tools + `tool_choice=auto` cause the model's reasoning/thinking output to degenerate into an endless stream of `!` ch...

---

### 4. #40155: [Bug] Spec-v2 workers diverge on forward_batch_generation signature — 4 of 7 missing pp_proxy_tensors the scheduler always passes

**链接:** [https://github.com/sgl-project/sglang/issues/40155](https://github.com/sgl-project/sglang/issues/40155)  
**评论数:** 1

**问题描述:**
### Describe the bug

The scheduler's non-overlap speculative path always passes `pp_proxy_tensors` to the spec worker:

- `srt/managers/scheduler.py:4514` and `:4527` — `self.model_worker.forward_batch_generation(batch, pp_proxy_tensors=pp_proxy_ten...

---

### 5. #43098: Agentic Cache Scheduling System Roadmap (Q4)

**链接:** [https://github.com/sgl-project/sglang/issues/43098](https://github.com/sgl-project/sglang/issues/43098)  
**评论数:** 2

**问题描述:**
## 1. Agentic Cache Scheduling

- Supernode-wide KV Cache Sharing @hzh0425  @Shunkangz
	- Enable sharing of GPU-resident (L1) and host-resident (L2) KV caches across engines within the same NVLink domain.
	- Add cache location awareness to the Router...

---

### 6. #42327: [Bug] DeepSeek V3 tool-call parser streams arguments "{}" when the closing fence and end tokens arrive in one stream event (MTP / --stream-interval > 1)

**链接:** [https://github.com/sgl-project/sglang/issues/42327](https://github.com/sgl-project/sglang/issues/42327)  
**评论数:** 0

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this i...

---

### 7. #37524: GLM-5.3-Flash bug tracking

**链接:** [https://github.com/sgl-project/sglang/issues/37524](https://github.com/sgl-project/sglang/issues/37524)  
**评论数:** 3

**问题描述:**
- [x] #36550
- [ ] #36653
- [ ] #36669
- [ ] #36711
- [ ] #36830
- [ ] #36886
- [ ] #36906
- [ ] #37548
- [ ] #37712
- [x] #37745
- [ ] #38031
- [x] #39692


---

### 8. #42373: [Bug] DeepSeekV31Detector streaming drops the arguments when a complete tool call arrives in one delta

**链接:** [https://github.com/sgl-project/sglang/issues/42373](https://github.com/sgl-project/sglang/issues/42373)  
**评论数:** 0

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this i...

---

### 9. #42508: [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

**链接:** [https://github.com/sgl-project/sglang/issues/42508](https://github.com/sgl-project/sglang/issues/42508)  
**评论数:** 2

**问题描述:**
# [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug pers...

---

### 10. #43324: [Bug] EP standard dispatch: -1 sentinel aliases to last local expert, padded spec-verify rows overflow masked-GEMM per-expert m_max (OOB stores, engine crash)

**链接:** [https://github.com/sgl-project/sglang/issues/43324](https://github.com/sgl-project/sglang/issues/43324)  
**评论数:** 0

**问题描述:**
## 🐛 Bug

Under expert parallelism with the standard (non-a2a) dispatcher and the DeepGEMM **masked standard** layout, CUDA-graph padded rows in speculative **verify** batches are masked to `topk_ids = -1` by the top-k post-pass — and `StandardDispat...

---

### 11. #17050: [Tracking] CI Test Failures and Fixes

**链接:** [https://github.com/sgl-project/sglang/issues/17050](https://github.com/sgl-project/sglang/issues/17050)  
**评论数:** 15

**问题描述:**
# [Tracking] CI Test Failures and Fixes

This issue tracks CI test failures, flaky tests, and infrastructure issues across SGLang's CI pipeline.

**Note:** We mainly focus on scheduled CI on the `main` branch.

**Last auto-update:** 2026-10-10 19:40 ...

---

### 12. #21302: [AITER-Upgrade] PR readiness

**链接:** [https://github.com/sgl-project/sglang/issues/21302](https://github.com/sgl-project/sglang/issues/21302)  
**评论数:** 37

**问题描述:**
# AITER Upgrade Readiness Tracker
> AITER Scout Status Tracking https://github.com/sgl-project/sglang/issues/26890

## What this issue tracks
Per AITER version that's in (or has been in) SGLang main, we track two things:
- New Feature: AITER PRs that...

---

### 13. #42917: [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4, symmetric, group 128) serves with degraded quality on 0.5.19-0.5.21 (wikitext PPL 9.98 vs 6.05 on vLLM, same checkpoint)

**链接:** [https://github.com/sgl-project/sglang/issues/42917](https://github.com/sgl-project/sglang/issues/42917)  
**评论数:** 2

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution. (Related, but different code path: #41835 is about `AutoRoundConfig`; this checkpoint loads through `CompressedTensorsConfig`.)
- [x] The bug persists in the latest version.
- [x] ...

---

### 14. #42369: [Bug][KV Cache] nvfp4 KV silently reuses the checkpoint's fp8-calibrated k/v_scale as NVFP4 global scale → deterministic long-context corruption (single-variable proof, sm_120)

**链接:** [https://github.com/sgl-project/sglang/issues/42369](https://github.com/sgl-project/sglang/issues/42369)  
**评论数:** 3

**问题描述:**
## TL;DR

Serving an NVFP4 KV cache (`--kv-cache-dtype nvfp4`) on a checkpoint whose `quantization_config.kv_cache_scheme` says `num_bits: 8` (e.g. unsloth's NVFP4 quants, which ship fp8-calibrated `k_scale`/`v_scale`) silently corrupts the KV cache:...

---

### 15. #34974: [Bug] --enable-eplb + --speculative-algorithm DSPARK crashes during draft CUDA graph capture: on_select_experts scatter_add_ dimension mismatch (layer_idx=None)

**链接:** [https://github.com/sgl-project/sglang/issues/34974](https://github.com/sgl-project/sglang/issues/34974)  
**评论数:** 5

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this i...

---

### 16. #44106: [Bug] `--enable-symm-mem`: the 4 GiB symmetric-memory pool and NCCL buffers are not taken out of `--mem-fraction-static`, so the server runs out of memory after start-up

**链接:** [https://github.com/sgl-project/sglang/issues/44106](https://github.com/sgl-project/sglang/issues/44106)  
**评论数:** 2

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution.
- [ ] The bug persists in the latest version. (Reproduced on v0.5.20 only. Main has the same memory accounting by code reading, see below. We ran a main nightly, `nightly-dev-20261...

---

### 17. #36333: [Bug] Disconnected streaming client leaves a zombie request that decodes to max_tokens and floods "state was deleted in TokenizerManager" (regression from #34160 revert)

**链接:** [https://github.com/sgl-project/sglang/issues/36333](https://github.com/sgl-project/sglang/issues/36333)  
**评论数:** 8

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this i...

---

## 🔴 困难难度 (3 个)

这些问题涉及性能优化、复杂算法或架构设计，需要深入理解 SGLang 内部机制。


### 1. #43239: [HiCache] NVFP4 KV + kernel io-backend: host pool row geometry mismatch and block scales never transported (packed MTP draft silently corrupted, accept length pinned to 1.0)

**链接:** [https://github.com/sgl-project/sglang/issues/43239](https://github.com/sgl-project/sglang/issues/43239)  
**评论数:** 0

**问题描述:**
**Environment**: Qwen3.8-27B NVFP4 checkpoint (GDN hybrid, 16 full-attention layers + packed NEXTN draft layer → 17), TP2, `--kv-cache-dtype nvfp4 --enable-hierarchical-cache --hicache-write-policy write_through --hicache-io-backend kernel --hicache-...

**难点:**
- 需要深入理解 SGLang 架构
- 可能涉及性能分析和优化
- 需要全面的测试验证

---

### 2. #33636: [NVIDIA] DeepSeek V4 Perf Tracking

**链接:** [https://github.com/sgl-project/sglang/issues/33636](https://github.com/sgl-project/sglang/issues/33636)  
**评论数:** 8

**问题描述:**
## Motivation

This follows [DeepSeek V4 Roadmap](https://github.com/sgl-project/sglang/issues/23602), which covers functional enablement; this issue is perf-only.

**Scope**: NVIDIA SM90 / SM10X.

---

## High priority

- [x] Integrate TRT-LLM DSv4 ...

**难点:**
- 需要深入理解 SGLang 架构
- 可能涉及性能分析和优化
- 需要全面的测试验证

---

### 3. #43096: Detokenizer return-path fanout performs one IPC send per request

**链接:** [https://github.com/sgl-project/sglang/issues/43096](https://github.com/sgl-project/sglang/issues/43096)  
**评论数:** 0

**问题描述:**

# Background

In multi-HTTP-worker mode, `MultiHttpWorkerDetokenizerMixin.multi_http_worker_event_loop()` splits each already-produced output into single-request messages and sends each one to its originating `http_worker_ipc`.

Multiple requests in...

**难点:**
- 需要深入理解 SGLang 架构
- 可能涉及性能分析和优化
- 需要全面的测试验证

---

## ⚠️ 需要多 GPU 环境 (3 个)

这些问题涉及多 GPU 并行（Tensor/Pipeline/Expert Parallelism），单卡 3090 可能无法完全复现，但可以尝试用双卡 3090 环境。


### 1. #36653: [Bug] NEXTN/MTP speculative decoding fails to load MTP MoE weights under TP>1 for Glm5NextForConditionalGeneration (GLM-5.3-Flash)

**链接:** [https://github.com/sgl-project/sglang/issues/36653](https://github.com/sgl-project/sglang/issues/36653)  
**评论数:** 2

**硬件要求:** Tensor Parallelism (multi-GPU), Tensor Parallelism (>1 GPU)

**问题描述:**
## Summary

Enabling NEXTN (MTP) speculative decoding for `Glm5NextForConditionalGeneration` (GLM-5.3-Flash) with `--tp-size 2` fails while loading the MTP layer's MoE weights. The **target** model loads and serves correctly with the identical comman...

---

### 2. #42397: [Bug] --speculative-token-map crashes at TP>1 (device-side assert in init_lm_head): global hot-token ids index a vocab-sharded lm_head

**链接:** [https://github.com/sgl-project/sglang/issues/42397](https://github.com/sgl-project/sglang/issues/42397)  
**评论数:** 0

**硬件要求:** Tensor Parallelism (>1 GPU)

**问题描述:**
### Checklist

- [ ] I searched related issues but found no solution.
- [ ] The bug persists in the latest version.
- [ ] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [ ] If this i...

---

### 3. #35822: [Bug] EAGLE speculative decoding (native Qwen3.5/3.8 MTP) hangs in tree_speculative_sampling_target_only on Ampere (2x A2, TP=2, 100% GPU util / low power)

**链接:** [https://github.com/sgl-project/sglang/issues/35822](https://github.com/sgl-project/sglang/issues/35822)  
**评论数:** 0

**硬件要求:** Tensor Parallelism (2 GPUs)

**问题描述:**
### Environment
- SGLang 0.5.17 (sglang-venv), flashinfer 0.6.15.post1
- 2x NVIDIA A2 (16GB each, sm_86 / Ampere), CUDA 13.3, NCCL 2.28.9
- TP=2, --kv-cache-dtype fp8_e5m2, --mem-fraction-static 0.90

### Model
- Qwen3.8-27B AWQ 4-bit VLM (arch qwen3...

---

## ❌ 需要特定硬件 (7 个)

这些问题需要特定的硬件环境（Blackwell GPU、AMD GPU、NPU 等），无法在 3090 上修复。


### 1. #44099: Qwen4-Exp (Qwen3.8-Flash-Next) QSA MTP: draft_tokens > compress ratio and topk > 1 crash late in scheduler init instead of failing arg validation

**链接:** [https://github.com/sgl-project/sglang/issues/44099](https://github.com/sgl-project/sglang/issues/44099)  
**硬件要求:** AMD ROCm

**说明:** 需要特定硬件环境，3090 无法复现

---

### 2. #42648: [Bug] PP + EAGLE/MTP spec decoding crashes with --enable-mixed-chunk: 'EagleDraftInput' object has no attribute 'rids' in _pp_spec_rebuild_verify_input

**链接:** [https://github.com/sgl-project/sglang/issues/42648](https://github.com/sgl-project/sglang/issues/42648)  
**硬件要求:** NPU

**说明:** 需要特定硬件环境，3090 无法复现

---

### 3. #42672: [Bug] NPU HiCache: MHATokenToKVPoolHost crashes when the device k_buffer is a single tensor (since #40326)

**链接:** [https://github.com/sgl-project/sglang/issues/42672](https://github.com/sgl-project/sglang/issues/42672)  
**硬件要求:** NPU

**说明:** 需要特定硬件环境，3090 无法复现

---

### 4. #36796: [Performance] Qwen4Exp decode on DGX Spark (SM121): QSA/PLE/GDN kernel time dominates; requests for SM121 tuning (QSA gather, GDN KDA backends, torch.compile+CUDA graph)

**链接:** [https://github.com/sgl-project/sglang/issues/36796](https://github.com/sgl-project/sglang/issues/36796)  
**硬件要求:** Blackwell SM121, NVIDIA DGX Spark, Tensor Parallelism (2 GPUs)

**说明:** 需要特定硬件环境，3090 无法复现

---

### 5. #35003: AMD Development Roadmap (2026 Q3)

**链接:** [https://github.com/sgl-project/sglang/issues/35003](https://github.com/sgl-project/sglang/issues/35003)  
**硬件要求:** AMD GPU

**说明:** 需要特定硬件环境，3090 无法复现

---

### 6. #42012: [Bug] GLM-5.3-Flash on SM120: fa4 attention backend crashes at CUDA-graph capture (hybrid extend reshape) — triton is the only working backend

**链接:** [https://github.com/sgl-project/sglang/issues/42012](https://github.com/sgl-project/sglang/issues/42012)  
**硬件要求:** Blackwell SM120

**说明:** 需要特定硬件环境，3090 无法复现

---

### 7. #37451: [Failure Tracker] PR Test (AMD)

**链接:** [https://github.com/sgl-project/sglang/issues/37451](https://github.com/sgl-project/sglang/issues/37451)  
**硬件要求:** AMD MI300, AMD ROCm, AMD GPU

**说明:** 需要特定硬件环境，3090 无法复现

---

## 💡 建议

### 优先级排序

**推荐先处理的 issue (简单 + 高影响):**
1. 从 2 个简单问题开始，快速建立信心
2. 选择评论多的中等难度问题（社区关注度高）
3. 逐步挑战困难问题

**3090 环境建议:**
- 单卡 3090 可以修复 22 个问题
- 如果有多卡环境，可以额外处理 3 个并行相关问题
- 建议先用小模型（如 7B/13B）复现问题，再在大模型上验证

**代码熟悉建议:**
1. 先阅读 SGLang 的 MTP/Speculative Decoding 相关代码
2. 理解 KV Cache 管理机制
3. 熟悉 Scheduler 和 Worker 的工作流程

---

*分析基于 issue 标题、描述和关键词，实际难度可能因个人经验而异*
