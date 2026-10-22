# #44145: [Bug][Speculative] EAGLE/MTP causes 90% KV cache starvation on models with untied embeddings (Fix Included)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @deguzguy |
| **Created** | 2026-10-13 |
| **Last Updated** | 2026-10-13 |
| **Comments** | 0 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/44145](https://github.com/sgl-project/sglang/issues/44145)

## Description

### Bug Description
When running EAGLE/MTP speculative decoding on models with untied embeddings (`tie_word_embeddings: false`) and large vocabularies (e.g. Qwen 2.5 / Qwen 3.x with vocab 248,320), the draft model allocates its own BF16 `embed_tokens` and `ParallelLMHead` (~4.74 GiB total).

In SGLang v0.5.21 (`docker.io/lmsysorg/sglang:v0.5.21-cu130`), `init_target_memory_pool()` in `srt/managers/scheduler.py` runs **before** `EagleDraftWorker.alloc_memory_pool()`. Because `init_lm_head()` / `s

---

*Generated: 2026-10-14 15:07:13*
