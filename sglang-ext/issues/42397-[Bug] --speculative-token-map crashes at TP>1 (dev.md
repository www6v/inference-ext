# #42397: [Bug] --speculative-token-map crashes at TP>1 (device-side assert in init_lm_head): global hot-token ids index a vocab-sharded lm_head

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @xin-osaka-u |
| **Created** | 2026-10-03 |
| **Last Updated** | 2026-10-03 |
| **Comments** | 0 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/42397](https://github.com/sgl-project/sglang/issues/42397)

## Description

### Checklist

- [ ] I searched related issues but found no solution.
- [ ] The bug persists in the latest version.
- [ ] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [ ] If this is not a bug report but a general question, please start a discussion at https://github.com/sgl-project/sglang/discussions. Otherwise, it will be closed.
- [ ] Please use English. Otherwise, it will be closed.

### Describe the bug

With `--speculativ

---

*Generated: 2026-10-14 15:07:13*
