# #43324: [Bug] EP standard dispatch: -1 sentinel aliases to last local expert, padded spec-verify rows overflow masked-GEMM per-expert m_max (OOB stores, engine crash)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @number-eleven11 |
| **Created** | 2026-10-09 |
| **Last Updated** | 2026-10-09 |
| **Comments** | 0 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/43324](https://github.com/sgl-project/sglang/issues/43324)

## Description

## 🐛 Bug

Under expert parallelism with the standard (non-a2a) dispatcher and the DeepGEMM **masked standard** layout, CUDA-graph padded rows in speculative **verify** batches are masked to `topk_ids = -1` by the top-k post-pass — and `StandardDispatcher` then re-labels them to the **last local expert** because advanced indexing wraps negative indices to the final entry of `local_expert_mapping`. The per-expert count kernel (`fused_moe_dispatch_index`) treats those fake assignments as real, so a

---

*Generated: 2026-10-14 15:07:13*
