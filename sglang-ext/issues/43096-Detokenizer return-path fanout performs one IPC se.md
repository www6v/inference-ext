# #43096: Detokenizer return-path fanout performs one IPC send per request

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @hope1262946533 |
| **Created** | 2026-10-08 |
| **Last Updated** | 2026-10-08 |
| **Comments** | 0 |
| **Labels** | None |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/43096](https://github.com/sgl-project/sglang/issues/43096)

## Description


# Background

In multi-HTTP-worker mode, `MultiHttpWorkerDetokenizerMixin.multi_http_worker_event_loop()` splits each already-produced output into single-request messages and sends each one to its originating `http_worker_ipc`.

Multiple requests in one output batch often belong to the same TokenizerWorker. The current loop therefore repeats object construction, serialization, and IPC sends for the same destination. This is the **Detokenizer → TokenizerWorker return hop**, not the Scheduler → M

---

*Generated: 2026-10-14 15:07:13*
