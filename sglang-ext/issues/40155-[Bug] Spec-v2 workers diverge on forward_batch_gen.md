# #40155: [Bug] Spec-v2 workers diverge on forward_batch_generation signature — 4 of 7 missing pp_proxy_tensors the scheduler always passes

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @JustinTong0323 |
| **Created** | 2026-09-18 |
| **Last Updated** | 2026-10-14 |
| **Comments** | 1 |
| **Labels** | bug |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/40155](https://github.com/sgl-project/sglang/issues/40155)

## Description

### Describe the bug

The scheduler's non-overlap speculative path always passes `pp_proxy_tensors` to the spec worker:

- `srt/managers/scheduler.py:4514` and `:4527` — `self.model_worker.forward_batch_generation(batch, pp_proxy_tensors=pp_proxy_tensors)`

But the spec-v2 workers have diverged on this signature. Audit of `python/sglang/srt/speculative/` on current `main`:

| Worker | `pp_proxy_tensors` |
|---|---|
| `eagle_worker_v2.py` | ✅ has it |
| `dflash_worker_v2.py` | ✅ has it |
| `ngram

---

*Generated: 2026-10-14 15:07:13*
