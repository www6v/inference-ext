# #42369: [Bug][KV Cache] nvfp4 KV silently reuses the checkpoint's fp8-calibrated k/v_scale as NVFP4 global scale → deterministic long-context corruption (single-variable proof, sm_120)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @chengye75-star |
| **Created** | 2026-10-03 |
| **Last Updated** | 2026-10-03 |
| **Comments** | 3 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/42369](https://github.com/sgl-project/sglang/issues/42369)

## Description

## TL;DR

Serving an NVFP4 KV cache (`--kv-cache-dtype nvfp4`) on a checkpoint whose `quantization_config.kv_cache_scheme` says `num_bits: 8` (e.g. unsloth's NVFP4 quants, which ship fp8-calibrated `k_scale`/`v_scale`) silently corrupts the KV cache: 32 tiny `[1]` bf16 scalars are loaded verbatim and consumed as the NVFP4 **global scale**. Removing exactly those 64 **bytes** flips long-context needle from 1/4 to 4/4 on an otherwise bit-identical 22.5 GB checkpoint. No log line ever mentions scal

---

*Generated: 2026-10-14 15:07:13*
