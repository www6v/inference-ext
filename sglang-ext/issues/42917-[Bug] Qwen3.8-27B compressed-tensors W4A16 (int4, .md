# #42917: [Bug] Qwen3.8-27B compressed-tensors W4A16 (int4, symmetric, group 128) serves with degraded quality on 0.5.19-0.5.21 (wikitext PPL 9.98 vs 6.05 on vLLM, same checkpoint)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @jolpindo96 |
| **Created** | 2026-10-07 |
| **Last Updated** | 2026-10-10 |
| **Comments** | 2 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/42917](https://github.com/sgl-project/sglang/issues/42917)

## Description

### Checklist

- [x] I searched related issues but found no solution. (Related, but different code path: #41835 is about `AutoRoundConfig`; this checkpoint loads through `CompressedTensorsConfig`.)
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please start a discussion at https://github.com/sgl-project/sglang/discussions.

---

*Generated: 2026-10-14 15:07:13*
