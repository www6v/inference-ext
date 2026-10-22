# #35822: [Bug] EAGLE speculative decoding (native Qwen3.5/3.8 MTP) hangs in tree_speculative_sampling_target_only on Ampere (2x A2, TP=2, 100% GPU util / low power)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @sebrinass |
| **Created** | 2026-08-21 |
| **Last Updated** | 2026-10-05 |
| **Comments** | 0 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/35822](https://github.com/sgl-project/sglang/issues/35822)

## Description

### Environment
- SGLang 0.5.17 (sglang-venv), flashinfer 0.6.15.post1
- 2x NVIDIA A2 (16GB each, sm_86 / Ampere), CUDA 13.3, NCCL 2.28.9
- TP=2, --kv-cache-dtype fp8_e5m2, --mem-fraction-static 0.90

### Model
- Qwen3.8-27B AWQ 4-bit VLM (arch qwen3_5 + qwen3_5_vision, hybrid GDN/mamba)

### Server config (native in-checkpoint MTP, no draft-model-path)
--speculative-algorithm EAGLE --speculative-num-steps 3 --speculative-eagle-topk 1 --speculative-num-draft-tokens 4
--mamba-ssm-dtype bfloat16 -

---

*Generated: 2026-10-14 15:07:13*
