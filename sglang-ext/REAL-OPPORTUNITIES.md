# SGLang MTP Issues - 真正可修复的 Issue (无 PR)

**分析日期:** 2026-10-14 15:28:11  
**GPU 环境:** NVIDIA RTX 3090 (24GB VRAM, SM86 Ampere)

---

## 📊 重要发现

经过检查所有 32 个 issue 的关联 PR，发现：
- ❌ **26 个 issue 已有相关 PR** (已合并或进行中)
- ✅ **6 个 issue 真正没有 PR** (可以贡献)

本文档只分析这 **6 个真正可以贡献的 issue**。

---

## 🎯 6 个可贡献的 Issue


### 🟡 中等难度 (5 个)


#### 1. #44145: [Bug][Speculative] EAGLE/MTP causes 90% KV cache starvation on models with untied embeddings (Fix Included)

**链接:** [https://github.com/sgl-project/sglang/issues/44145](https://github.com/sgl-project/sglang/issues/44145)  
**评论数:** 0

**问题描述:**
### Bug Description
When running EAGLE/MTP speculative decoding on models with untied embeddings (`tie_word_embeddings: false`) and large vocabularies (e.g. Qwen 2.5 / Qwen 3.x with vocab 248,320), the draft model allocates its own BF16 `embed_tokens` and `ParallelLMHead` (~4.74 GiB total).

In SGLang v0.5.21 (`docker.io/lmsysorg/sglang:v0.5.21-cu130`), `init_target_memory_pool()` in `srt/managers...

---

#### 2. #43098: Agentic Cache Scheduling System Roadmap (Q4)

**链接:** [https://github.com/sgl-project/sglang/issues/43098](https://github.com/sgl-project/sglang/issues/43098)  
**评论数:** 2

**问题描述:**
## 1. Agentic Cache Scheduling

- Supernode-wide KV Cache Sharing @hzh0425  @Shunkangz
	- Enable sharing of GPU-resident (L1) and host-resident (L2) KV caches across engines within the same NVLink domain.
	- Add cache location awareness to the Router to coordinate request placement and KV transfers based on cache availability and engine load.
	- Extend HiCache linker integration to support GPU-to-...

---

#### 3. #37524: GLM-5.3-Flash bug tracking

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

#### 4. #42508: [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

**链接:** [https://github.com/sgl-project/sglang/issues/42508](https://github.com/sgl-project/sglang/issues/42508)  
**评论数:** 2

**问题描述:**
# [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version. (occurred on `nightly-dev-20261003-65f75914`)
- [x] I included environment info and logs. (full crash dump + `server_args`...

---

#### 5. #42917: [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4, symmetric, group 128) serves with degraded quality on 0.5.19-0.5.21 (wikitext PPL 9.98 vs 6.05 on vLLM, same checkpoint)

**链接:** [https://github.com/sgl-project/sglang/issues/42917](https://github.com/sgl-project/sglang/issues/42917)  
**评论数:** 2

**问题描述:**
### Checklist

- [x] I searched related issues but found no solution. (Related, but different code path: #41835 is about `AutoRoundConfig`; this checkpoint loads through `CompressedTensorsConfig`.)
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but...

---


## 💡 建议

### 优先级排序

1. **#44145** - EAGLE/MTP KV cache 饥饿问题
   - 用户已提供修复方案
   - 影响大（90% KV cache 占用）
   - 建议优先处理

2. **#42508** - Scheduler 内存损坏崩溃
   - 严重 bug（double free）
   - 导致服务器永久挂起
   - 高优先级

3. **#42917** - Qwen3.8-27B 量化质量问题
   - 精度下降问题
   - 需要对比 vLLM 实现
   - 中等难度

4. **#43098** - Agentic Cache 调度路线图
   - 规划类任务
   - 需要深入理解架构

5. **#37524** - GLM-5.3-Flash bug 跟踪
   - 跟踪类任务
   - 需要持续测试

### 3090 环境

所有 6 个 issue 都可以在单卡 3090 上复现和修复！

---

## 📋 完整列表

| # | Issue | 难度 | 评论 | 可在 3090 修复 |
|---|-------|------|------|----------------|
| 35003 | AMD Development Roadmap (2026 Q3) | 🟡 | 1 | ❌ |
| 37524 | GLM-5.3-Flash bug tracking | 🟡 | 3 | ✅ |
| 42508 | [Bug] Scheduler aborts with `double free or corrup | 🟡 | 2 | ✅ |
| 42917 | [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4,  | 🟡 | 2 | ✅ |
| 43098 | Agentic Cache Scheduling System Roadmap (Q4) | 🟡 | 2 | ✅ |
| 44145 | [Bug][Speculative] EAGLE/MTP causes 90% KV cache s | 🟡 | 0 | ✅ |


---

*这些是真正可以为 SGLang 贡献的机会！*
