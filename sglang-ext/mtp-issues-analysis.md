# SGLang MTP (Multi-Token Prediction) Issues Analysis

**Generated:** 2026-10-14 15:07:13  
**Filter Criteria:**
- Related to MTP (Multi-Token Prediction)
- No associated Pull Requests (issues only)
- Updated after 2026-10-01
- **Status: Open only (excluded closed issues)**
- **Excluded: Feature requests and Roadmap issues**

**Total Issues:** 32

---

## Summary

- **Total Open Issues:** 32
- **Total Comments:** 117

---

## Issues List

### 1. #40155: [Bug] Spec-v2 workers diverge on forward_batch_generation signature — 4 of 7 missing pp_proxy_tensors the scheduler always passes

**Author:** @JustinTong0323  
**Created:** 2026-09-18  
**Last Updated:** 2026-10-14  
**Comments:** 1  
**Labels:** bug

**Link:** [https://github.com/sgl-project/sglang/issues/40155](https://github.com/sgl-project/sglang/issues/40155)

**Description Preview:**
### Describe the bug

The scheduler's non-overlap speculative path always passes `pp_proxy_tensors` to the spec worker:

- `srt/managers/scheduler.py:4514` and `:4527` — `self.model_worker.forward_batch_generation(batch, pp_proxy_tensors=pp_proxy_tensors)`

But the spec-v2 workers have diverged on t...

---

### 2. #42012: [Bug] GLM-5.3-Flash on SM120: fa4 attention backend crashes at CUDA-graph capture (hybrid extend reshape) — triton is the only working backend

**Author:** @Lei-010  
**Created:** 2026-10-01  
**Last Updated:** 2026-10-14  
**Comments:** 11  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42012](https://github.com/sgl-project/sglang/issues/42012)

**Description Preview:**
# GLM-5.3-Flash on SM120 (RTX PRO 6000): attention backend matrix — fa4 crashes on hybrid extend, triton is the only working path

## Environment

- 8× NVIDIA RTX PRO 6000 (SM120, 96 GB each), driver/CUDA as stock
- SGLang `lmsysorg/sglang:v0.5.20` docker image (built 2026-09-18)
- Model: `zai-org/G...

---

### 3. #43098: Agentic Cache Scheduling System Roadmap (Q4)

**Author:** @hzh0425  
**Created:** 2026-10-08  
**Last Updated:** 2026-10-14  
**Comments:** 2  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/43098](https://github.com/sgl-project/sglang/issues/43098)

**Description Preview:**
## 1. Agentic Cache Scheduling

- Supernode-wide KV Cache Sharing @hzh0425  @Shunkangz
	- Enable sharing of GPU-resident (L1) and host-resident (L2) KV caches across engines within the same NVLink domain.
	- Add cache location awareness to the Router to coordinate request placement and KV transfers ...

---

### 4. #44106: [Bug] `--enable-symm-mem`: the 4 GiB symmetric-memory pool and NCCL buffers are not taken out of `--mem-fraction-static`, so the server runs out of memory after start-up

**Author:** @bvolpato  
**Created:** 2026-10-13  
**Last Updated:** 2026-10-14  
**Comments:** 2  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/44106](https://github.com/sgl-project/sglang/issues/44106)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution.
- [ ] The bug persists in the latest version. (Reproduced on v0.5.20 only. Main has the same memory accounting by code reading, see below. We ran a main nightly, `nightly-dev-20261011-d32d8fa0`, on TP8 with `--enable-symm-mem` onl...

---

### 5. #37451: [Failure Tracker] PR Test (AMD)

**Author:** @bingxche  
**Created:** 2026-09-01  
**Last Updated:** 2026-10-14  
**Comments:** 0  
**Labels:** ci-failure-tracker

**Link:** [https://github.com/sgl-project/sglang/issues/37451](https://github.com/sgl-project/sglang/issues/37451)

**Description Preview:**
<!-- ci-failure-tracker:start -->
<!-- ci-failure-tracker-state:
{
"[job] call-pr-test-amd-extra / extra-a-test-1-gpu-large-amd (rocm700, linux-mi300-1gpu-sglang)::N/A (collection-time import crash; no test executed)": {
"test_file": "[job] call-pr-test-amd-extra / extra-a-test-1-gpu-large-amd (rocm...

---

### 6. #44099: Qwen4-Exp (Qwen3.8-Flash-Next) QSA MTP: draft_tokens > compress ratio and topk > 1 crash late in scheduler init instead of failing arg validation

**Author:** @florianleibert  
**Created:** 2026-10-13  
**Last Updated:** 2026-10-14  
**Comments:** 1  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/44099](https://github.com/sgl-project/sglang/issues/44099)

**Description Preview:**
### Description

Serving `Qwen/Qwen3.8-Flash-Next-FP8` (Qwen4-Exp arch, QSA sparse attention) with EAGLE/MTP speculative decoding on ROCm. Two separate hard crashes at startup, both raising `NotImplementedError` deep inside scheduler init instead of being validated up front in `handle_server_args`:
...

---

### 7. #44145: [Bug][Speculative] EAGLE/MTP causes 90% KV cache starvation on models with untied embeddings (Fix Included)

**Author:** @deguzguy  
**Created:** 2026-10-13  
**Last Updated:** 2026-10-13  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/44145](https://github.com/sgl-project/sglang/issues/44145)

**Description Preview:**
### Bug Description
When running EAGLE/MTP speculative decoding on models with untied embeddings (`tie_word_embeddings: false`) and large vocabularies (e.g. Qwen 2.5 / Qwen 3.x with vocab 248,320), the draft model allocates its own BF16 `embed_tokens` and `ParallelLMHead` (~4.74 GiB total).

In SGLa...

---

### 8. #17050: [Tracking] CI Test Failures and Fixes

**Author:** @alisonshao  
**Created:** 2026-01-14  
**Last Updated:** 2026-10-13  
**Comments:** 15  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/17050](https://github.com/sgl-project/sglang/issues/17050)

**Description Preview:**
# [Tracking] CI Test Failures and Fixes

This issue tracks CI test failures, flaky tests, and infrastructure issues across SGLang's CI pipeline.

**Note:** We mainly focus on scheduled CI on the `main` branch.

**Last auto-update:** 2026-10-10 19:40 UTC — 1 broken, 4 flaky, 1165 recently fixed

## Q...

---

### 9. #21302: [AITER-Upgrade] PR readiness

**Author:** @HaiShaw  
**Created:** 2026-03-24  
**Last Updated:** 2026-10-13  
**Comments:** 37  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/21302](https://github.com/sgl-project/sglang/issues/21302)

**Description Preview:**
# AITER Upgrade Readiness Tracker
> AITER Scout Status Tracking https://github.com/sgl-project/sglang/issues/26890

## What this issue tracks
Per AITER version that's in (or has been in) SGLang main, we track two things:
- New Feature: AITER PRs that SGLang features depend on, and whether both the A...

---

### 10. #37524: GLM-5.3-Flash bug tracking

**Author:** @kpham-sgl  
**Created:** 2026-09-02  
**Last Updated:** 2026-10-13  
**Comments:** 3  
**Labels:** bug, GLM

**Link:** [https://github.com/sgl-project/sglang/issues/37524](https://github.com/sgl-project/sglang/issues/37524)

**Description Preview:**
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

### 11. #33713: unified_cache: MAMBA component nodes are pruned instead of downgraded on device eviction, breaking host-tier loadback

**Author:** @JustinTong0323  
**Created:** 2026-08-05  
**Last Updated:** 2026-10-11  
**Comments:** 3  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/33713](https://github.com/sgl-project/sglang/issues/33713)

**Description Preview:**
## Symptom

When the unified radix cache evicts a node whose model uses the MAMBA (hybrid-KDA) component, the node is pruned outright from the radix tree instead of being downgraded to host-resident. A subsequent request for the same prefix never even attempts H→D load-back and reports `cached_token...

---

### 12. #42917: [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4, symmetric, group 128) serves with degraded quality on 0.5.19-0.5.21 (wikitext PPL 9.98 vs 6.05 on vLLM, same checkpoint)

**Author:** @jolpindo96  
**Created:** 2026-10-07  
**Last Updated:** 2026-10-10  
**Comments:** 2  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42917](https://github.com/sgl-project/sglang/issues/42917)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution. (Related, but different code path: #41835 is about `AutoRoundConfig`; this checkpoint loads through `CompressedTensorsConfig`.)
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal repr...

---

### 13. #36333: [Bug] Disconnected streaming client leaves a zombie request that decodes to max_tokens and floods "state was deleted in TokenizerManager" (regression from #34160 revert)

**Author:** @wkgcass  
**Created:** 2026-08-25  
**Last Updated:** 2026-10-09  
**Comments:** 8  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/36333](https://github.com/sgl-project/sglang/issues/36333)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please ...

---

### 14. #43324: [Bug] EP standard dispatch: -1 sentinel aliases to last local expert, padded spec-verify rows overflow masked-GEMM per-expert m_max (OOB stores, engine crash)

**Author:** @number-eleven11  
**Created:** 2026-10-09  
**Last Updated:** 2026-10-09  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/43324](https://github.com/sgl-project/sglang/issues/43324)

**Description Preview:**
## 🐛 Bug

Under expert parallelism with the standard (non-a2a) dispatcher and the DeepGEMM **masked standard** layout, CUDA-graph padded rows in speculative **verify** batches are masked to `topk_ids = -1` by the top-k post-pass — and `StandardDispatcher` then re-labels them to the **last local expe...

---

### 15. #36796: [Performance] Qwen4Exp decode on DGX Spark (SM121): QSA/PLE/GDN kernel time dominates; requests for SM121 tuning (QSA gather, GDN KDA backends, torch.compile+CUDA graph)

**Author:** @leego  
**Created:** 2026-08-28  
**Last Updated:** 2026-10-09  
**Comments:** 3  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/36796](https://github.com/sgl-project/sglang/issues/36796)

**Description Preview:**
# [Performance] Qwen4Exp (Qwen3.8-Flash-Next) decode on DGX Spark (GB10/SM121): QSA + PLE kernels dominate step time

## Environment
- 2× NVIDIA DGX Spark (GB10, SM121, 128GB unified), TP=2 over direct CX7 200Gb RoCEv2
- Image: lmsysorg/sglang:qwen38flashnext + SM121 QSA Triton fallback patch (as sh...

---

### 16. #43239: [HiCache] NVFP4 KV + kernel io-backend: host pool row geometry mismatch and block scales never transported (packed MTP draft silently corrupted, accept length pinned to 1.0)

**Author:** @chengye75-star  
**Created:** 2026-10-08  
**Last Updated:** 2026-10-08  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/43239](https://github.com/sgl-project/sglang/issues/43239)

**Description Preview:**
**Environment**: Qwen3.8-27B NVFP4 checkpoint (GDN hybrid, 16 full-attention layers + packed NEXTN draft layer → 17), TP2, `--kv-cache-dtype nvfp4 --enable-hierarchical-cache --hicache-write-policy write_through --hicache-io-backend kernel --hicache-mem-layout page_first --page-size 64 --speculative...

---

### 17. #36669: [Bug] GLM-5.3-Flash thinking output degenerates into repeated '!' under multi-tool agentic prompts

**Author:** @ech0potato  
**Created:** 2026-08-27  
**Last Updated:** 2026-10-08  
**Comments:** 4  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/36669](https://github.com/sgl-project/sglang/issues/36669)

**Description Preview:**
## Summary

When serving zai-org/GLM-5.3-Flash (native FP8 checkpoint) with SGLang, requests with a complex system prompt + multiple tools + `tool_choice=auto` cause the model's reasoning/thinking output to degenerate into an endless stream of `!` characters. Simple requests work correctly.

## Envi...

---

### 18. #43096: Detokenizer return-path fanout performs one IPC send per request

**Author:** @hope1262946533  
**Created:** 2026-10-08  
**Last Updated:** 2026-10-08  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/43096](https://github.com/sgl-project/sglang/issues/43096)

**Description Preview:**

# Background

In multi-HTTP-worker mode, `MultiHttpWorkerDetokenizerMixin.multi_http_worker_event_loop()` splits each already-produced output into single-request messages and sends each one to its originating `http_worker_ipc`.

Multiple requests in one output batch often belong to the same Tokeniz...

---

### 19. #42510: [Bug] EAGLE/MTP same-checkpoint draft keeps redundant embed_tokens/lm_head copies resident during KV pool sizing → under-sized pool, startup OOM

**Author:** @paulalesius  
**Created:** 2026-10-04  
**Last Updated:** 2026-10-07  
**Comments:** 1  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42510](https://github.com/sgl-project/sglang/issues/42510)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please ...

---

### 20. #36653: [Bug] NEXTN/MTP speculative decoding fails to load MTP MoE weights under TP>1 for Glm5NextForConditionalGeneration (GLM-5.3-Flash)

**Author:** @moshemalawach  
**Created:** 2026-08-27  
**Last Updated:** 2026-10-07  
**Comments:** 2  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/36653](https://github.com/sgl-project/sglang/issues/36653)

**Description Preview:**
## Summary

Enabling NEXTN (MTP) speculative decoding for `Glm5NextForConditionalGeneration` (GLM-5.3-Flash) with `--tp-size 2` fails while loading the MTP layer's MoE weights. The **target** model loads and serves correctly with the identical command minus the four `--speculative-*` flags; only the...

---

### 21. #42648: [Bug] PP + EAGLE/MTP spec decoding crashes with --enable-mixed-chunk: 'EagleDraftInput' object has no attribute 'rids' in _pp_spec_rebuild_verify_input

**Author:** @jhsmith409  
**Created:** 2026-10-05  
**Last Updated:** 2026-10-07  
**Comments:** 1  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42648](https://github.com/sgl-project/sglang/issues/42648)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please ...

---

### 22. #42672: [Bug] NPU HiCache: MHATokenToKVPoolHost crashes when the device k_buffer is a single tensor (since #40326)

**Author:** @pingqiu  
**Created:** 2026-10-05  
**Last Updated:** 2026-10-06  
**Comments:** 1  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42672](https://github.com/sgl-project/sglang/issues/42672)

**Description Preview:**
### Describe the bug

`test/registered/npu/basic_function/HiCache/test_npu_hicache_mha.py` fails on `main` (PR Test (NPU), e.g. runs 37358858354 and 37376161789). The server dies while building the HiCache host pool:

```
File ".../mem_cache/pool_host/mha.py", line 160, in <genexpr>
    for buf in g...

---

### 23. #35822: [Bug] EAGLE speculative decoding (native Qwen3.5/3.8 MTP) hangs in tree_speculative_sampling_target_only on Ampere (2x A2, TP=2, 100% GPU util / low power)

**Author:** @sebrinass  
**Created:** 2026-08-21  
**Last Updated:** 2026-10-05  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/35822](https://github.com/sgl-project/sglang/issues/35822)

**Description Preview:**
### Environment
- SGLang 0.5.17 (sglang-venv), flashinfer 0.6.15.post1
- 2x NVIDIA A2 (16GB each, sm_86 / Ampere), CUDA 13.3, NCCL 2.28.9
- TP=2, --kv-cache-dtype fp8_e5m2, --mem-fraction-static 0.90

### Model
- Qwen3.8-27B AWQ 4-bit VLM (arch qwen3_5 + qwen3_5_vision, hybrid GDN/mamba)

### Server...

---

### 24. #42508: [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

**Author:** @LUOSENGWA  
**Created:** 2026-10-04  
**Last Updated:** 2026-10-05  
**Comments:** 2  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42508](https://github.com/sgl-project/sglang/issues/42508)

**Description Preview:**
# [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version. (occurred on `nightly-...

---

### 25. #33636: [NVIDIA] DeepSeek V4 Perf Tracking

**Author:** @b8zhong  
**Created:** 2026-08-05  
**Last Updated:** 2026-10-04  
**Comments:** 8  
**Labels:** nvidia

**Link:** [https://github.com/sgl-project/sglang/issues/33636](https://github.com/sgl-project/sglang/issues/33636)

**Description Preview:**
## Motivation

This follows [DeepSeek V4 Roadmap](https://github.com/sgl-project/sglang/issues/23602), which covers functional enablement; this issue is perf-only.

**Scope**: NVIDIA SM90 / SM10X.

---

## High priority

- [x] Integrate TRT-LLM DSv4 attention for SM100/103 #30805
- [x] FlashInfer MN...

---

### 26. #42369: [Bug][KV Cache] nvfp4 KV silently reuses the checkpoint's fp8-calibrated k/v_scale as NVFP4 global scale → deterministic long-context corruption (single-variable proof, sm_120)

**Author:** @chengye75-star  
**Created:** 2026-10-03  
**Last Updated:** 2026-10-03  
**Comments:** 3  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42369](https://github.com/sgl-project/sglang/issues/42369)

**Description Preview:**
## TL;DR

Serving an NVFP4 KV cache (`--kv-cache-dtype nvfp4`) on a checkpoint whose `quantization_config.kv_cache_scheme` says `num_bits: 8` (e.g. unsloth's NVFP4 quants, which ship fp8-calibrated `k_scale`/`v_scale`) silently corrupts the KV cache: 32 tiny `[1]` bf16 scalars are loaded verbatim an...

---

### 27. #42397: [Bug] --speculative-token-map crashes at TP>1 (device-side assert in init_lm_head): global hot-token ids index a vocab-sharded lm_head

**Author:** @xin-osaka-u  
**Created:** 2026-10-03  
**Last Updated:** 2026-10-03  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42397](https://github.com/sgl-project/sglang/issues/42397)

**Description Preview:**
### Checklist

- [ ] I searched related issues but found no solution.
- [ ] The bug persists in the latest version.
- [ ] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [ ] If this is not a bug report but a general question, please ...

---

### 28. #42373: [Bug] DeepSeekV31Detector streaming drops the arguments when a complete tool call arrives in one delta

**Author:** @he-yufeng  
**Created:** 2026-10-03  
**Last Updated:** 2026-10-03  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42373](https://github.com/sgl-project/sglang/issues/42373)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please ...

---

### 29. #42327: [Bug] DeepSeek V3 tool-call parser streams arguments "{}" when the closing fence and end tokens arrive in one stream event (MTP / --stream-interval > 1)

**Author:** @wenqiw777  
**Created:** 2026-10-03  
**Last Updated:** 2026-10-03  
**Comments:** 0  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42327](https://github.com/sgl-project/sglang/issues/42327)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please ...

---

### 30. #42217: MultiDetokenizerRouter splits each batch into per-request IPC sends

**Author:** @hope1262946533  
**Created:** 2026-10-02  
**Last Updated:** 2026-10-02  
**Comments:** 1  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/42217](https://github.com/sgl-project/sglang/issues/42217)

**Description Preview:**

## Summary

In SGLang 0.5.17, `MultiDetokenizerRouter` receives a batch from the scheduler but forwards a batch request by splitting it into one output message per request. In a multi-tokenizer/multi-detokenizer deployment, this makes the single router perform one serialization and IPC send for eve...

---

### 31. #34974: [Bug] --enable-eplb + --speculative-algorithm DSPARK crashes during draft CUDA graph capture: on_select_experts scatter_add_ dimension mismatch (layer_idx=None)

**Author:** @SAXEM1997  
**Created:** 2026-08-15  
**Last Updated:** 2026-10-02  
**Comments:** 5  
**Labels:** None

**Link:** [https://github.com/sgl-project/sglang/issues/34974](https://github.com/sgl-project/sglang/issues/34974)

**Description Preview:**
### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please ...

---

### 32. #35003: AMD Development Roadmap (2026 Q3)

**Author:** @HaiShaw  
**Created:** 2026-08-16  
**Last Updated:** 2026-10-02  
**Comments:** 1  
**Labels:** amd

**Link:** [https://github.com/sgl-project/sglang/issues/35003](https://github.com/sgl-project/sglang/issues/35003)

**Description Preview:**
# AMD SGLang Roadmap — 2026 Q3

*Contributions and feedback are welcome*. [Join SGLang Slack channel](https://sgl-fru7574.slack.com/archives/C09TPAM1N68).

## Focus

- **New Hardware support & higher performance**: Helios rack scale system, MI45x (gfx1250) GPUs, Ryzen AI Halo (gfx1151/1152) platform...

---

