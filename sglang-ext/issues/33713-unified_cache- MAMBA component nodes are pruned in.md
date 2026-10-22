# #33713: unified_cache: MAMBA component nodes are pruned instead of downgraded on device eviction, breaking host-tier loadback

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @JustinTong0323 |
| **Created** | 2026-08-05 |
| **Last Updated** | 2026-10-11 |
| **Comments** | 3 |
| **Labels** | None |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/33713](https://github.com/sgl-project/sglang/issues/33713)

## Description

## Symptom

When the unified radix cache evicts a node whose model uses the MAMBA (hybrid-KDA) component, the node is pruned outright from the radix tree instead of being downgraded to host-resident. A subsequent request for the same prefix never even attempts H→D load-back and reports `cached_tokens_details=None` (no `host > 0` hit), even though the backup chain committed pages to the host tier correctly.

## Repro

1. Serve any hybrid-KDA model with:

```
--enable-hierarchical-cache --mamba-sc

---

*Generated: 2026-10-14 15:07:13*
