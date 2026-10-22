# #36653: [Bug] NEXTN/MTP speculative decoding fails to load MTP MoE weights under TP>1 for Glm5NextForConditionalGeneration (GLM-5.3-Flash)

## Metadata

| Field | Value |
|-------|-------|
| **Author** | @moshemalawach |
| **Created** | 2026-08-27 |
| **Last Updated** | 2026-10-07 |
| **Comments** | 2 |
| **Labels** | None |
| **Category** | bug |

## Links

- **GitHub Issue:** [https://github.com/sgl-project/sglang/issues/36653](https://github.com/sgl-project/sglang/issues/36653)

## Description

## Summary

Enabling NEXTN (MTP) speculative decoding for `Glm5NextForConditionalGeneration` (GLM-5.3-Flash) with `--tp-size 2` fails while loading the MTP layer's MoE weights. The **target** model loads and serves correctly with the identical command minus the four `--speculative-*` flags; only the draft/MTP worker fails.

The shapes suggest the draft model's `FusedMoE` is constructed **unsharded** while the weight loader supplies the **TP-sharded** slice.

## Environment

- Image: `lmsysorg/sg

---

*Generated: 2026-10-14 15:07:13*
