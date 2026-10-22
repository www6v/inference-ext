# #42672: [Bug] NPU HiCache: MHATokenToKVPoolHost crashes when the device k_buffer is a single tensor (since #40326)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @pingqiu |
| **Created** | 2026-10-05 |
| **Last Updated** | 2026-10-06 |
| **Comments** | 1 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/42672](https://github.com/sgl-project/sglang/issues/42672)

## Description

### Describe the bug

`test/registered/npu/basic_function/HiCache/test_npu_hicache_mha.py` fails on `main` (PR Test (NPU), e.g. runs 37358858354 and 37376161789). The server dies while building the HiCache host pool:

```
File ".../mem_cache/pool_host/mha.py", line 160, in <genexpr>
    for buf in getattr(pool, side, None) or ()
RuntimeError: Boolean value of Tensor with more than one value is ambiguous
```

### Cause

#40326 ("Derive KV row addresses from strides, not shapes (1/7)") added this 

---

*Generated: 2026-10-14 15:07:13*
