# #42508: [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @LUOSENGWA |
| **Created** | 2026-10-04 |
| **Last Updated** | 2026-10-05 |
| **Comments** | 2 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/42508](https://github.com/sgl-project/sglang/issues/42508)

## Description

# [Bug] Scheduler aborts with `double free or corruption` inside the idle-loop invariant check (`session_held_tokens` walk); server hangs permanently afterwards

### Checklist

- [x] I searched related issues but found no solution.
- [x] The bug persists in the latest version. (occurred on `nightly-dev-20261003-65f75914`)
- [x] I included environment info and logs. (full crash dump + `server_args` below; a py-spy capture will be added if it recurs)
- [x] This is a bug report.

### Describe the b

---

*Generated: 2026-10-14 15:07:13*
