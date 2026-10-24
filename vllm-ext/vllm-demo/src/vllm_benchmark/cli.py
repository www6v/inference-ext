"""
vLLM Benchmark - GPU Performance Testing via vLLM Engine
Tests: Throughput, Latency, TTFT (Time To First Token)
"""

import argparse
import json
import os
import statistics
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import torch

from vllm import LLM, SamplingParams


# Try to import modelscope for ModelScope downloads
try:
    from modelscope import snapshot_download
    MODELSCOPE_AVAILABLE = True
except ImportError:
    MODELSCOPE_AVAILABLE = False
    snapshot_download = None


@dataclass
class BenchmarkResult:
    """Single benchmark result."""
    label: str = ""
    elapsed_s: float = 0.0
    prompt_tokens: int = 0
    completion_tokens: int = 0
    tokens_per_sec: float = 0.0
    ttft_ms: float = 0.0
    ttft_s: float = 0.0


@dataclass
class BenchmarkReport:
    """Complete benchmark report."""
    model: str = ""
    gpu: str = ""
    gpu_memory_gb: int = 0
    latency_results: list[BenchmarkResult] = field(default_factory=list)
    concurrent_results: list[BenchmarkResult] = field(default_factory=list)
    wall_time_s: float = 0.0


class VLLMBenchmark:
    """vLLM benchmark runner."""

    DEFAULT_MODEL = "cyankiwi/Qwen3.6-35B-A3B-AWQ-4bit"

    def __init__(
        self,
        model: str | None = None,
        trust_remote_code: bool = True,
        gpu_memory_utilization: float = 0.85,
        max_model_len: int = 4096,
        download_dir: str | None = None,
        load_format: str = "auto",
        quantization: str | None = None,  # None = auto-detect from model config
        use_modelscope: bool = True,
    ):
        self.model_name = model or self.DEFAULT_MODEL
        self.gtrust_remote_code = trust_remote_code
        self.gpu_memory_utilization = gpu_memory_utilization
        self.max_model_len = max_model_len
        self.download_dir = download_dir or "./models"
        self.load_format = load_format
        self.quantization = quantization
        self.use_modelscope = use_modelscope
        self.llm: LLM | None = None
        self._report = BenchmarkReport()

    def download_from_modelscope(self, model_id: str) -> str:
        """Download model from ModelScope and return local path."""
        if not MODELSCOPE_AVAILABLE:
            raise ImportError("modelscope library not installed. Run: pip install modelscope")

        cache_dir = os.path.join(self.download_dir, model_id.replace("/", "_"))
        print(f"Downloading model from ModelScope: {model_id}")
        print(f"Cache directory: {cache_dir}")

        snapshot_download(
            model_id=model_id,
            cache_dir=cache_dir,
        )
        return cache_dir

    def init_model(self) -> None:
        """Initialize vLLM engine."""
        model_path = self.model_name
        is_local_path = Path(model_path).exists()

        # Download from ModelScope if specified
        if self.use_modelscope and MODELSCOPE_AVAILABLE and not is_local_path:
            try:
                model_path = self.download_from_modelscope(self.model_name)
                # ModelScope downloads to snapshots/master
                snapshots_path = Path(model_path) / "snapshots" / "master"
                if snapshots_path.exists():
                    model_path = str(snapshots_path)
            except Exception as e:
                print(f"ModelScope download failed: {e}")
                print("Falling back to HuggingFace...")
                self.use_modelscope = False

        print(f"Loading model: {model_path}")

        # Extra args for large models
        extra_kwargs = {}
        if self.load_format and self.load_format != "auto":
            extra_kwargs["load_format"] = self.load_format
        # Auto-detect quantization from model config
        if self.quantization:
            extra_kwargs["quantization"] = self.quantization

        self.llm = LLM(
            model=model_path,
            trust_remote_code=self.gtrust_remote_code,
            gpu_memory_utilization=self.gpu_memory_utilization,
            max_model_len=self.max_model_len,
            enforce_eager=True,
            limit_mm_per_prompt={"image": 0, "video": 0},  # Disable multimodal for text-only benchmark
            **extra_kwargs,
        )
        # Note: attention_backend is set via VLLM_ATTENTION_BACKEND env var
        print("Model loaded successfully")

    def _get_gpu_info(self) -> tuple[str, int]:
        """Get GPU name and memory."""
        if torch.cuda.is_available():
            gpu_name = torch.cuda.get_device_name(0)
            gpu_memory = torch.cuda.get_device_properties(0).total_memory // (1024**3)
            return gpu_name, gpu_memory
        return "Unknown", 0

    def benchmark_single(
        self,
        prompt: str,
        max_tokens: int,
        label: str = "",
    ) -> BenchmarkResult:
        """Run single benchmark."""
        sampling_params = SamplingParams(
            max_tokens=max_tokens,
            temperature=0.7,
            ignore_eos=False,
        )

        start = time.perf_counter()
        outputs = self.llm.generate([prompt], sampling_params)
        elapsed = time.perf_counter() - start

        output = outputs[0]
        prompt_tokens = len(output.prompt_token_ids)
        completion_tokens = len(output.outputs[0].token_ids)

        # vLLM provides detailed timing in outputs[0].metrics if available
        # Use elapsed time as fallback
        tps = completion_tokens / elapsed if elapsed > 0 else 0

        # TTFT estimation: use first token time if available, else estimate
        ttft_s = getattr(output.outputs[0], "time_to_first_token", 0.0)
        if ttft_s == 0 and elapsed > 0:
            # Rough estimate: first 10% of generation time
            ttft_s = elapsed * 0.1

        return BenchmarkResult(
            label=label,
            elapsed_s=round(elapsed, 3),
            prompt_tokens=prompt_tokens,
            completion_tokens=completion_tokens,
            tokens_per_sec=round(tps, 1),
            ttft_ms=round(ttft_s * 1000, 1),
            ttft_s=round(ttft_s, 3),
        )

    def benchmark_latency_sweep(
        self,
        prompt: str = "Write a short story about a robot learning to paint.",
        lengths: list[int] | None = None,
    ) -> list[BenchmarkResult]:
        """Benchmark with different output lengths."""
        if lengths is None:
            lengths = [32, 128, 512]

        print("\n=== Latency Sweep ===")
        results = []
        for n in lengths:
            r = self.benchmark_single(prompt, n, label=f"max_tokens={n}")
            results.append(r)
            print(f"  {r.label:20s} | {r.elapsed_s:6.2f}s | "
                  f"{r.completion_tokens:4d} tok | "
                  f"{r.tokens_per_sec:6.1f} tok/s | "
                  f"TTFT: {r.ttft_ms:.1f} ms")
        return results

    def benchmark_concurrent(
        self,
        n_requests: int = 5,
        max_tokens: int = 128,
        prompt: str = "Explain quantum computing in simple terms.",
    ) -> tuple[list[BenchmarkResult], float]:
        """Benchmark concurrent requests."""
        print(f"\n=== Concurrent Benchmark ({n_requests} parallel) ===")

        def do_request(i: int) -> BenchmarkResult:
            return self.benchmark_single(prompt, max_tokens, label=f"req-{i+1}")

        start = time.perf_counter()
        with ThreadPoolExecutor(max_workers=n_requests) as executor:
            results = list(executor.map(do_request, range(n_requests)))
        wall_time = time.perf_counter() - start

        total_completions = sum(r.completion_tokens for r in results)
        print(f"  Wall time: {wall_time:.2f}s")
        print(f"  Total: {total_completions} tokens")
        print(f"  Aggregate: {total_completions / wall_time:.1f} tok/s")
        print(f"  Per-request avg: {statistics.mean(r.tokens_per_sec for r in results):.1f} tok/s")

        return results, wall_time

    def run(self) -> BenchmarkReport:
        """Run full benchmark suite."""
        print("=" * 55)
        print("  vLLM GPU Benchmark")
        print(f"  Model: {self.model_name}")
        print("=" * 55)

        # Initialize
        self.init_model()

        # GPU info
        gpu_name, gpu_memory = self._get_gpu_info()
        self._report.gpu = gpu_name
        self._report.gpu_memory_gb = gpu_memory
        self._report.model = self.model_name

        print(f"\n  GPU: {gpu_name} ({gpu_memory}GB)")

        # Run benchmarks
        latency_results = self.benchmark_latency_sweep()
        concurrent_results, wall_time = self.benchmark_concurrent(n_requests=5, max_tokens=128)

        self._report.latency_results = latency_results
        self._report.concurrent_results = concurrent_results
        self._report.wall_time_s = wall_time

        # Summary
        avg_tps = statistics.mean(r.tokens_per_sec for r in latency_results)
        avg_ttft = statistics.mean(r.ttft_ms for r in latency_results)

        print("\n" + "=" * 55)
        print("  SUMMARY")
        print("=" * 55)
        print(f"  Model: {self.model_name}")
        print(f"  GPU: {gpu_name}")
        print(f"  Avg throughput (single): {avg_tps:.1f} tok/s")
        print(f"  Avg TTFT: {avg_ttft:.1f} ms")
        print(f"  Concurrent wall time: {wall_time:.1f}s")
        print("=" * 55)

        return self._report

    def save_report(self, report: BenchmarkReport, path: str | Path) -> None:
        """Save report to JSON file."""
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)

        data = {
            "model": report.model,
            "gpu": report.gpu,
            "gpu_memory_gb": report.gpu_memory_gb,
            "latency_results": [
                {
                    "label": r.label,
                    "elapsed_s": r.elapsed_s,
                    "prompt_tokens": r.prompt_tokens,
                    "completion_tokens": r.completion_tokens,
                    "tokens_per_sec": r.tokens_per_sec,
                    "ttft_ms": r.ttft_ms,
                }
                for r in report.latency_results
            ],
            "concurrent_results": [
                {
                    "label": r.label,
                    "elapsed_s": r.elapsed_s,
                    "prompt_tokens": r.prompt_tokens,
                    "completion_tokens": r.completion_tokens,
                    "tokens_per_sec": r.tokens_per_sec,
                    "ttft_ms": r.ttft_ms,
                }
                for r in report.concurrent_results
            ],
            "wall_time_s": report.wall_time_s,
        }

        with open(path, "w") as f:
            json.dump(data, f, indent=2)
        print(f"\nReport saved to: {path}")


def main():
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="vLLM GPU Benchmark - Test inference performance"
    )
    parser.add_argument(
        "--model",
        type=str,
        default=None,
        help="Model name or path (default: Qwen/Qwen3.8B-AWQ)",
    )
    parser.add_argument(
        "--max-model-len",
        type=int,
        default=4096,
        help="Maximum model length (default: 4096)",
    )
    parser.add_argument(
        "--gpu-memory-utilization",
        type=float,
        default=0.9,
        help="GPU memory utilization (default: 0.9)",
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Save report to JSON file",
    )
    parser.add_argument(
        "--concurrent",
        type=int,
        default=5,
        help="Number of concurrent requests (default: 5)",
    )

    args = parser.parse_args()

    benchmark = VLLMBenchmark(
        model=args.model,
        gpu_memory_utilization=args.gpu_memory_utilization,
        max_model_len=args.max_model_len,
    )

    report = benchmark.run()

    if args.output:
        benchmark.save_report(report, args.output)


if __name__ == "__main__":
    main()
