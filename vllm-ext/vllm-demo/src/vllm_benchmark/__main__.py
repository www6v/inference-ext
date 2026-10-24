"""CLI entry point for vllm-benchmark."""

import os

# Force V0 engine to avoid flashinfer compilation issues
os.environ["VLLM_ENABLE_V1"] = "0"

from vllm_benchmark.cli import main

if __name__ == "__main__":
    main()
