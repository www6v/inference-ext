# #44099: Qwen4-Exp (Qwen3.8-Flash-Next) QSA MTP: draft_tokens > compress ratio and topk > 1 crash late in scheduler init instead of failing arg validation

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @florianleibert |
| **Created** | 2026-10-13 |
| **Last Updated** | 2026-10-14 |
| **Comments** | 1 |
| **Labels** | None |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/44099](https://github.com/sgl-project/sglang/issues/44099)

## Description

### Description

Serving `Qwen/Qwen3.8-Flash-Next-FP8` (Qwen4-Exp arch, QSA sparse attention) with EAGLE/MTP speculative decoding on ROCm. Two separate hard crashes at startup, both raising `NotImplementedError` deep inside scheduler init instead of being validated up front in `handle_server_args`:

**1. `speculative_num_draft_tokens` > QSA compress ratio (4)**

```
--speculative-algorithm EAGLE --speculative-num-steps 4 --speculative-eagle-topk 1 --speculative-num-draft-tokens 6
```

```
NotImp

---

*Generated: 2026-10-14 15:07:13*
