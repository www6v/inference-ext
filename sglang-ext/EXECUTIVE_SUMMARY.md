# SGLang MTP Issues - Executive Summary (Filtered)

**Report Date:** 2026-10-14 15:07:35  
**Analysis Period:** Issues updated after 2026-10-01  
**Repository:** sgl-project/sglang

---

## Filter Applied

- ✅ **Included:** Open issues only
- ❌ **Excluded:** Closed issues (21 removed)
- ❌ **Excluded:** Feature requests [Feature] (7 removed)
- ❌ **Excluded:** Roadmap issues [Roadmap] (6 removed)

**Total Removed:** 34 issues  
**Remaining Issues:** 32

---

## Key Findings

### Overview
- **Total Issues:** 32
- **Bug Reports:** 19 (59%)
- **Tracking Issues:** 1
- **RFC:** 0
- **Other:** 12

### Critical Observations

1. **Bug Dominance:** 19 out of 32 issues (59%) are bug reports - indicates significant stability challenges
2. **Active Issues:** 23 issues have community engagement
3. **Recent Activity:** All issues updated after 2026-10-01

---

## Most Active Issues (by discussion)


### 1. #21302: [AITER-Upgrade] PR readiness
- **Comments:** 37
- **Link:** https://github.com/sgl-project/sglang/issues/21302

### 2. #17050: [Tracking] CI Test Failures and Fixes
- **Comments:** 15
- **Link:** https://github.com/sgl-project/sglang/issues/17050

### 3. #42012: [Bug] GLM-5.3-Flash on SM120: fa4 attention backend crashes at CUDA-graph capture (hybrid extend reshape) — triton is the only working backend
- **Comments:** 11
- **Link:** https://github.com/sgl-project/sglang/issues/42012

### 4. #33636: [NVIDIA] DeepSeek V4 Perf Tracking
- **Comments:** 8
- **Link:** https://github.com/sgl-project/sglang/issues/33636

### 5. #36333: [Bug] Disconnected streaming client leaves a zombie request that decodes to max_tokens and floods "state was deleted in TokenizerManager" (regression from #34160 revert)
- **Comments:** 8
- **Link:** https://github.com/sgl-project/sglang/issues/36333

### 6. #34974: [Bug] --enable-eplb + --speculative-algorithm DSPARK crashes during draft CUDA graph capture: on_select_experts scatter_add_ dimension mismatch (layer_idx=None)
- **Comments:** 5
- **Link:** https://github.com/sgl-project/sglang/issues/34974

### 7. #36669: [Bug] GLM-5.3-Flash thinking output degenerates into repeated '!' under multi-tool agentic prompts
- **Comments:** 4
- **Link:** https://github.com/sgl-project/sglang/issues/36669

### 8. #37524: GLM-5.3-Flash bug tracking
- **Comments:** 3
- **Link:** https://github.com/sgl-project/sglang/issues/37524

### 9. #36796: [Performance] Qwen4Exp decode on DGX Spark (SM121): QSA/PLE/GDN kernel time dominates; requests for SM121 tuning (QSA gather, GDN KDA backends, torch.compile+CUDA graph)
- **Comments:** 3
- **Link:** https://github.com/sgl-project/sglang/issues/36796

### 10. #33713: unified_cache: MAMBA component nodes are pruned instead of downgraded on device eviction, breaking host-tier loadback
- **Comments:** 3
- **Link:** https://github.com/sgl-project/sglang/issues/33713


---

## Most Recently Updated Issues


### 1. #40155: [Bug] Spec-v2 workers diverge on forward_batch_generation signature — 4 of 7 missing pp_proxy_tensors the scheduler always passes
- **Last Updated:** 2026-10-14
- **Link:** https://github.com/sgl-project/sglang/issues/40155

### 2. #42012: [Bug] GLM-5.3-Flash on SM120: fa4 attention backend crashes at CUDA-graph capture (hybrid extend reshape) — triton is the only working backend
- **Last Updated:** 2026-10-14
- **Link:** https://github.com/sgl-project/sglang/issues/42012

### 3. #43098: Agentic Cache Scheduling System Roadmap (Q4)
- **Last Updated:** 2026-10-14
- **Link:** https://github.com/sgl-project/sglang/issues/43098

### 4. #44106: [Bug] `--enable-symm-mem`: the 4 GiB symmetric-memory pool and NCCL buffers are not taken out of `--mem-fraction-static`, so the server runs out of memory after start-up
- **Last Updated:** 2026-10-14
- **Link:** https://github.com/sgl-project/sglang/issues/44106

### 5. #37451: [Failure Tracker] PR Test (AMD)
- **Last Updated:** 2026-10-14
- **Link:** https://github.com/sgl-project/sglang/issues/37451

### 6. #44099: Qwen4-Exp (Qwen3.8-Flash-Next) QSA MTP: draft_tokens > compress ratio and topk > 1 crash late in scheduler init instead of failing arg validation
- **Last Updated:** 2026-10-14
- **Link:** https://github.com/sgl-project/sglang/issues/44099

### 7. #44145: [Bug][Speculative] EAGLE/MTP causes 90% KV cache starvation on models with untied embeddings (Fix Included)
- **Last Updated:** 2026-10-13
- **Link:** https://github.com/sgl-project/sglang/issues/44145

### 8. #17050: [Tracking] CI Test Failures and Fixes
- **Last Updated:** 2026-10-13
- **Link:** https://github.com/sgl-project/sglang/issues/17050

### 9. #21302: [AITER-Upgrade] PR readiness
- **Last Updated:** 2026-10-13
- **Link:** https://github.com/sgl-project/sglang/issues/21302

### 10. #37524: GLM-5.3-Flash bug tracking
- **Last Updated:** 2026-10-13
- **Link:** https://github.com/sgl-project/sglang/issues/37524


---

## All Bug Reports

**Total Bugs:** 19


1. **#44145** - [Bug][Speculative] EAGLE/MTP causes 90% KV cache starvation on models with untied embeddings (Fix Included)
   - Created: 2026-10-13 | Updated: 2026-10-13
   - Comments: 0
   - Link: https://github.com/sgl-project/sglang/issues/44145

2. **#36653** - [Bug] NEXTN/MTP speculative decoding fails to load MTP MoE weights under TP>1 for Glm5NextForConditionalGeneration (GLM-5.3-Flash)
   - Created: 2026-08-27 | Updated: 2026-10-07
   - Comments: 2
   - Link: https://github.com/sgl-project/sglang/issues/36653

3. **#42510** - [Bug] EAGLE/MTP same-checkpoint draft keeps redundant embed_tokens/lm_head copies resident during KV pool sizing → under-sized pool, startup OOM
   - Created: 2026-10-04 | Updated: 2026-10-07
   - Comments: 1
   - Link: https://github.com/sgl-project/sglang/issues/42510

4. **#36669** - [Bug] GLM-5.3-Flash thinking output degenerates into repeated '!' under multi-tool agentic prompts
   - Created: 2026-08-27 | Updated: 2026-10-08
   - Comments: 4
   - Link: https://github.com/sgl-project/sglang/issues/36669

5. **#40155** - [Bug] Spec-v2 workers diverge on forward_batch_generation signature — 4 of 7 missing pp_proxy_tensors the scheduler always passes
   - Created: 2026-09-18 | Updated: 2026-10-14
   - Comments: 1
   - Link: https://github.com/sgl-project/sglang/issues/40155

6. **#42397** - [Bug] --speculative-token-map crashes at TP>1 (device-side assert in init_lm_head): global hot-token ids index a vocab-sharded lm_head
   - Created: 2026-10-03 | Updated: 2026-10-03
   - Comments: 0
   - Link: https://github.com/sgl-project/sglang/issues/42397

7. **#42648** - [Bug] PP + EAGLE/MTP spec decoding crashes with --enable-mixed-chunk: 'EagleDraftInput' object has no attribute 'rids' in _pp_spec_rebuild_verify_input
   - Created: 2026-10-05 | Updated: 2026-10-07
   - Comments: 1
   - Link: https://github.com/sgl-project/sglang/issues/42648

8. **#42327** - [Bug] DeepSeek V3 tool-call parser streams arguments "{}" when the closing fence and end tokens arrive in one stream event (MTP / --stream-interval > 1)
   - Created: 2026-10-03 | Updated: 2026-10-03
   - Comments: 0
   - Link: https://github.com/sgl-project/sglang/issues/42327

9. **#42672** - [Bug] NPU HiCache: MHATokenToKVPoolHost crashes when the device k_buffer is a single tensor (since #40326)
   - Created: 2026-10-05 | Updated: 2026-10-06
   - Comments: 1
   - Link: https://github.com/sgl-project/sglang/issues/42672

10. **#35822** - [Bug] EAGLE speculative decoding (native Qwen3.5/3.8 MTP) hangs in tree_speculative_sampling_target_only on Ampere (2x A2, TP=2, 100% GPU util / low power)
   - Created: 2026-08-21 | Updated: 2026-10-05
   - Comments: 0
   - Link: https://github.com/sgl-project/sglang/issues/35822

11. **#42373** - [Bug] DeepSeekV31Detector streaming drops the arguments when a complete tool call arrives in one delta
   - Created: 2026-10-03 | Updated: 2026-10-03
   - Comments: 0
   - Link: https://github.com/sgl-project/sglang/issues/42373

12. **#42508** - [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards
   - Created: 2026-10-04 | Updated: 2026-10-05
   - Comments: 2
   - Link: https://github.com/sgl-project/sglang/issues/42508

13. **#43324** - [Bug] EP standard dispatch: -1 sentinel aliases to last local expert, padded spec-verify rows overflow masked-GEMM per-expert m_max (OOB stores, engine crash)
   - Created: 2026-10-09 | Updated: 2026-10-09
   - Comments: 0
   - Link: https://github.com/sgl-project/sglang/issues/43324

14. **#42917** - [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4, symmetric, group 128) serves with degraded quality on 0.5.19-0.5.21 (wikitext PPL 9.98 vs 6.05 on vLLM, same checkpoint)
   - Created: 2026-10-07 | Updated: 2026-10-10
   - Comments: 2
   - Link: https://github.com/sgl-project/sglang/issues/42917

15. **#42369** - [Bug][KV Cache] nvfp4 KV silently reuses the checkpoint's fp8-calibrated k/v_scale as NVFP4 global scale → deterministic long-context corruption (single-variable proof, sm_120)
   - Created: 2026-10-03 | Updated: 2026-10-03
   - Comments: 3
   - Link: https://github.com/sgl-project/sglang/issues/42369

16. **#34974** - [Bug] --enable-eplb + --speculative-algorithm DSPARK crashes during draft CUDA graph capture: on_select_experts scatter_add_ dimension mismatch (layer_idx=None)
   - Created: 2026-08-15 | Updated: 2026-10-02
   - Comments: 5
   - Link: https://github.com/sgl-project/sglang/issues/34974

17. **#42012** - [Bug] GLM-5.3-Flash on SM120: fa4 attention backend crashes at CUDA-graph capture (hybrid extend reshape) — triton is the only working backend
   - Created: 2026-10-01 | Updated: 2026-10-14
   - Comments: 11
   - Link: https://github.com/sgl-project/sglang/issues/42012

18. **#44106** - [Bug] `--enable-symm-mem`: the 4 GiB symmetric-memory pool and NCCL buffers are not taken out of `--mem-fraction-static`, so the server runs out of memory after start-up
   - Created: 2026-10-13 | Updated: 2026-10-14
   - Comments: 2
   - Link: https://github.com/sgl-project/sglang/issues/44106

19. **#36333** - [Bug] Disconnected streaming client leaves a zombie request that decodes to max_tokens and floods "state was deleted in TokenizerManager" (regression from #34160 revert)
   - Created: 2026-08-25 | Updated: 2026-10-09
   - Comments: 8
   - Link: https://github.com/sgl-project/sglang/issues/36333


---

## Recommendations

1. **Priority Focus:** 19 bug reports require attention
2. **High Impact:** Address issues with most comments first
3. **Stability:** High bug count suggests need for improved testing
4. **Documentation:** Consider improving MTP documentation

---

## File Structure

- `mtp-issues-analysis.md` - Complete list of 32 filtered issues
- `issues/` - Individual markdown files for each issue
- `issues/README.md` - Categorized summary

---

*Generated automatically from GitHub API data*
