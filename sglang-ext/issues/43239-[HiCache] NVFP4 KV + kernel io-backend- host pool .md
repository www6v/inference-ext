# #43239: [HiCache] NVFP4 KV + kernel io-backend: host pool row geometry mismatch and block scales never transported (packed MTP draft silently corrupted, accept length pinned to 1.0)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @chengye75-star |
| **Created** | 2026-10-08 |
| **Last Updated** | 2026-10-08 |
| **Comments** | 0 |
| **Labels** | None |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/43239](https://github.com/sgl-project/sglang/issues/43239)

## Description

**Environment**: Qwen3.8-27B NVFP4 checkpoint (GDN hybrid, 16 full-attention layers + packed NEXTN draft layer → 17), TP2, `--kv-cache-dtype nvfp4 --enable-hierarchical-cache --hicache-write-policy write_through --hicache-io-backend kernel --hicache-mem-layout page_first --page-size 64 --speculative-algorithm NEXTN`. Reproduced deterministically on v0.5.21; **the same geometry is still present on current `main`** (`pool_host/mha.py:219-222` sizes host rows from device *element* counts; no FP4-aw

---

*Generated: 2026-10-14 15:07:13*
