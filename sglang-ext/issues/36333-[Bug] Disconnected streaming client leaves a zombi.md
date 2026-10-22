# #36333: [Bug] Disconnected streaming client leaves a zombie request that decodes to max_tokens and floods "state was deleted in TokenizerManager" (regression from #34160 revert)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @wkgcass |
| **Created** | 2026-08-25 |
| **Last Updated** | 2026-10-09 |
| **Comments** | 8 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/36333](https://github.com/sgl-project/sglang/issues/36333)

## Description

### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version.
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may receive no feedback.
- [x] If this is not a bug report but a general question, please start a discussion at https://github.com/sgl-project/sglang/discussions. Otherwise, it will be closed.
- [x] Please use English. Otherwise, it will be closed.

### Describe the bug

> Submitted by GLM

---

*Generated: 2026-10-14 15:07:13*
