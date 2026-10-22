# #36796: [Performance] Qwen4Exp decode on DGX Spark (SM121): QSA/PLE/GDN kernel time dominates; requests for SM121 tuning (QSA gather, GDN KDA backends, torch.compile+CUDA graph)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @leego |
| **Created** | 2026-08-28 |
| **Last Updated** | 2026-10-09 |
| **Comments** | 3 |
| **Labels** | None |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/36796](https://github.com/sgl-project/sglang/issues/36796)

## Description

# [Performance] Qwen4Exp (Qwen3.8-Flash-Next) decode on DGX Spark (GB10/SM121): QSA + PLE kernels dominate step time

## Environment
- 2× NVIDIA DGX Spark (GB10, SM121, 128GB unified), TP=2 over direct CX7 200Gb RoCEv2
- Image: lmsysorg/sglang:qwen38flashnext + SM121 QSA Triton fallback patch (as shipped by MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks)
- Model: RadixArk/Qwen3.8-Flash-Next-NVFP4 (176B MoE, 6B active, GDN 3:1 QSA, PLE n-gram table fp8-offloaded)
- NEXTN 3/1/4, decode CUDA graphs o

---

*Generated: 2026-10-14 15:07:13*
