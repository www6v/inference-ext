# #44106: [Bug] `--enable-symm-mem`: the 4 GiB symmetric-memory pool and NCCL buffers are not taken out of `--mem-fraction-static`, so the server runs out of memory after start-up

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @bvolpato |
| **Created** | 2026-10-13 |
| **Last Updated** | 2026-10-14 |
| **Comments** | 2 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/44106](https://github.com/sgl-project/sglang/issues/44106)

## Description

### Checklist

- [x] I searched related issues but found no solution.
- [ ] The bug persists in the latest version. (Reproduced on v0.5.20 only. Main has the same memory accounting by code reading, see below. We ran a main nightly, `nightly-dev-20261011-d32d8fa0`, on TP8 with `--enable-symm-mem` only at `--mem-fraction-static 0.88`, where it works. We did not run main with the failing settings.)
- [x] Issues without environment info and a minimal reproducible demo are hard to resolve and may rec

---

*Generated: 2026-10-14 15:07:13*
