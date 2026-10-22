# #43098: Agentic Cache Scheduling System Roadmap (Q4)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @hzh0425 |
| **Created** | 2026-10-08 |
| **Last Updated** | 2026-10-14 |
| **Comments** | 2 |
| **Labels** | None |
| **Category** | other |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/43098](https://github.com/sgl-project/sglang/issues/43098)

## Description

## 1. Agentic Cache Scheduling

- Supernode-wide KV Cache Sharing @hzh0425  @Shunkangz
	- Enable sharing of GPU-resident (L1) and host-resident (L2) KV caches across engines within the same NVLink domain.
	- Add cache location awareness to the Router to coordinate request placement and KV transfers based on cache availability and engine load.
	- Extend HiCache linker integration to support GPU-to-GPU KV transfers over NVLink and remote Grace DRAM access through EGM.
	- Optimize small KV-page tra

---

*Generated: 2026-10-14 15:07:13*
