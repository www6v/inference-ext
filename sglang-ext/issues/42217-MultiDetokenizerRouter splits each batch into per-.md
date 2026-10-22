# #42217: MultiDetokenizerRouter splits each batch into per-request IPC sends

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @hope1262946533 |
| **Created** | 2026-10-02 |
| **Last Updated** | 2026-10-02 |
| **Comments** | 1 |
| **Labels** | None |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/42217](https://github.com/sgl-project/sglang/issues/42217)

## Description


## Summary

In SGLang 0.5.17, `MultiDetokenizerRouter` receives a batch from the scheduler but forwards a batch request by splitting it into one output message per request. In a multi-tokenizer/multi-detokenizer deployment, this makes the single router perform one serialization and IPC send for every request even when many requests in the same scheduler batch have the same target detokenizer.

This can make the router the capacity bottleneck of the output path. Requests that have already progre

---

*Generated: 2026-10-14 15:07:13*
