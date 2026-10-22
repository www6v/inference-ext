# MTP Issues - Categorized Summary (Filtered)

**Generated:** 2026-10-14 15:07:13

**Filter Applied:**
- ✅ Open issues only
- ❌ Excluded: Closed issues
- ❌ Excluded: Feature requests [Feature]
- ❌ Excluded: Roadmap issues [Roadmap]

## Categories Overview


### Bug Reports (19 issues)

- [#40155](https://github.com/sgl-project/sglang/issues/40155) - [Bug] Spec-v2 workers diverge on forward_batch_generation signature — 4 of 7 missing pp_proxy_tensors the scheduler always passes
- [#42012](https://github.com/sgl-project/sglang/issues/42012) - [Bug] GLM-5.3-Flash on SM120: fa4 attention backend crashes at CUDA-graph capture (hybrid extend reshape) — triton is the only working backend
- [#44106](https://github.com/sgl-project/sglang/issues/44106) - [Bug] `--enable-symm-mem`: the 4 GiB symmetric-memory pool and NCCL buffers are not taken out of `--mem-fraction-static`, so the server runs out of memory after start-up
- [#44145](https://github.com/sgl-project/sglang/issues/44145) - [Bug][Speculative] EAGLE/MTP causes 90% KV cache starvation on models with untied embeddings (Fix Included)
- [#42917](https://github.com/sgl-project/sglang/issues/42917) - [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4, symmetric, group 128) serves with degraded quality on 0.5.19-0.5.21 (wikitext PPL 9.98 vs 6.05 on vLLM, same checkpoint)
- [#36333](https://github.com/sgl-project/sglang/issues/36333) - [Bug] Disconnected streaming client leaves a zombie request that decodes to max_tokens and floods "state was deleted in TokenizerManager" (regression from #34160 revert)
- [#43324](https://github.com/sgl-project/sglang/issues/43324) - [Bug] EP standard dispatch: -1 sentinel aliases to last local expert, padded spec-verify rows overflow masked-GEMM per-expert m_max (OOB stores, engine crash)
- [#36669](https://github.com/sgl-project/sglang/issues/36669) - [Bug] GLM-5.3-Flash thinking output degenerates into repeated '!' under multi-tool agentic prompts
- [#42510](https://github.com/sgl-project/sglang/issues/42510) - [Bug] EAGLE/MTP same-checkpoint draft keeps redundant embed_tokens/lm_head copies resident during KV pool sizing → under-sized pool, startup OOM
- [#36653](https://github.com/sgl-project/sglang/issues/36653) - [Bug] NEXTN/MTP speculative decoding fails to load MTP MoE weights under TP>1 for Glm5NextForConditionalGeneration (GLM-5.3-Flash)
- [#42648](https://github.com/sgl-project/sglang/issues/42648) - [Bug] PP + EAGLE/MTP spec decoding crashes with --enable-mixed-chunk: 'EagleDraftInput' object has no attribute 'rids' in _pp_spec_rebuild_verify_input
- [#42672](https://github.com/sgl-project/sglang/issues/42672) - [Bug] NPU HiCache: MHATokenToKVPoolHost crashes when the device k_buffer is a single tensor (since #40326)
- [#35822](https://github.com/sgl-project/sglang/issues/35822) - [Bug] EAGLE speculative decoding (native Qwen3.5/3.8 MTP) hangs in tree_speculative_sampling_target_only on Ampere (2x A2, TP=2, 100% GPU util / low power)
- [#42508](https://github.com/sgl-project/sglang/issues/42508) - [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards
- [#42369](https://github.com/sgl-project/sglang/issues/42369) - [Bug][KV Cache] nvfp4 KV silently reuses the checkpoint's fp8-calibrated k/v_scale as NVFP4 global scale → deterministic long-context corruption (single-variable proof, sm_120)
- [#42397](https://github.com/sgl-project/sglang/issues/42397) - [Bug] --speculative-token-map crashes at TP>1 (device-side assert in init_lm_head): global hot-token ids index a vocab-sharded lm_head
- [#42373](https://github.com/sgl-project/sglang/issues/42373) - [Bug] DeepSeekV31Detector streaming drops the arguments when a complete tool call arrives in one delta
- [#42327](https://github.com/sgl-project/sglang/issues/42327) - [Bug] DeepSeek V3 tool-call parser streams arguments "{}" when the closing fence and end tokens arrive in one stream event (MTP / --stream-interval > 1)
- [#34974](https://github.com/sgl-project/sglang/issues/34974) - [Bug] --enable-eplb + --speculative-algorithm DSPARK crashes during draft CUDA graph capture: on_select_experts scatter_add_ dimension mismatch (layer_idx=None)

### Other (12 issues)

- [#43098](https://github.com/sgl-project/sglang/issues/43098) - Agentic Cache Scheduling System Roadmap (Q4)
- [#37451](https://github.com/sgl-project/sglang/issues/37451) - [Failure Tracker] PR Test (AMD)
- [#44099](https://github.com/sgl-project/sglang/issues/44099) - Qwen4-Exp (Qwen3.8-Flash-Next) QSA MTP: draft_tokens > compress ratio and topk > 1 crash late in scheduler init instead of failing arg validation
- [#21302](https://github.com/sgl-project/sglang/issues/21302) - [AITER-Upgrade] PR readiness
- [#37524](https://github.com/sgl-project/sglang/issues/37524) - GLM-5.3-Flash bug tracking
- [#33713](https://github.com/sgl-project/sglang/issues/33713) - unified_cache: MAMBA component nodes are pruned instead of downgraded on device eviction, breaking host-tier loadback
- [#36796](https://github.com/sgl-project/sglang/issues/36796) - [Performance] Qwen4Exp decode on DGX Spark (SM121): QSA/PLE/GDN kernel time dominates; requests for SM121 tuning (QSA gather, GDN KDA backends, torch.compile+CUDA graph)
- [#43239](https://github.com/sgl-project/sglang/issues/43239) - [HiCache] NVFP4 KV + kernel io-backend: host pool row geometry mismatch and block scales never transported (packed MTP draft silently corrupted, accept length pinned to 1.0)
- [#43096](https://github.com/sgl-project/sglang/issues/43096) - Detokenizer return-path fanout performs one IPC send per request
- [#33636](https://github.com/sgl-project/sglang/issues/33636) - [NVIDIA] DeepSeek V4 Perf Tracking
- [#42217](https://github.com/sgl-project/sglang/issues/42217) - MultiDetokenizerRouter splits each batch into per-request IPC sends
- [#35003](https://github.com/sgl-project/sglang/issues/35003) - AMD Development Roadmap (2026 Q3)

### Tracking Issues (1 issues)

- [#17050](https://github.com/sgl-project/sglang/issues/17050) - [Tracking] CI Test Failures and Fixes
