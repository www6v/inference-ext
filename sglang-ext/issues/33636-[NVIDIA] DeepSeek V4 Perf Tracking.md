# #33636: [NVIDIA] DeepSeek V4 Perf Tracking

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @b8zhong |
| **Created** | 2026-08-05 |
| **Last Updated** | 2026-10-04 |
| **Comments** | 8 |
| **Labels** | nvidia |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/33636](https://github.com/sgl-project/sglang/issues/33636)

## Description

## Motivation

This follows [DeepSeek V4 Roadmap](https://github.com/sgl-project/sglang/issues/23602), which covers functional enablement; this issue is perf-only.

**Scope**: NVIDIA SM90 / SM10X.

---

## High priority

- [x] Integrate TRT-LLM DSv4 attention for SM100/103 #30805
- [x] FlashInfer MNNVL backend for pure (non-fused) allreduce #30700
- [ ] Overlap scheduling for online C128 MTP #30497
- [ ] Split mixed-chunk attention: route decode tokens to the fp8 paged MLA kernel #30338
- [x] Em

---

*Generated: 2026-10-14 15:07:13*
