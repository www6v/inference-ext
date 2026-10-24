#!/usr/bin/env python3
"""
GPU Performance Benchmark via Ollama OpenAI-compatible API
Tests: Throughput, Latency, TTFT (Time To First Token)
"""

import json
import time
import statistics
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor

API_BASE = "http://localhost:11434"
MODEL = "gemma4:26b"


def api_request(endpoint, data):
    url = f"{API_BASE}{endpoint}"
    req = urllib.request.Request(
        url,
        data=json.dumps(data).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))


def check_server():
    print("Checking ollama server...")
    for i in range(30):
        try:
            req = urllib.request.Request(f"{API_BASE}/api/tags")
            with urllib.request.urlopen(req, timeout=5) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                models = [m["name"] for m in data.get("models", [])]
                print(f"  Server ready. Models: {models}")
                return True
        except Exception:
            print(f"  Waiting... ({i+1}/30)")
            time.sleep(3)
    print("ERROR: Server not responding")
    return False


def benchmark_single(prompt, max_tokens, label=""):
    """Single request benchmark using /api/generate."""
    data = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {
            "num_predict": max_tokens,
            "temperature": 0.7,
        }
    }
    start = time.perf_counter()
    result = api_request("/api/generate", data)
    elapsed = time.perf_counter() - start

    prompt_tokens = result.get("prompt_eval_count", 0)
    completion_tokens = result.get("eval_count", 0)
    eval_duration = result.get("eval_duration", 0) / 1e9  # ns to s
    prompt_eval_duration = result.get("prompt_eval_duration", 0) / 1e9
    total_duration = result.get("total_duration", 0) / 1e9

    tps = completion_tokens / eval_duration if eval_duration > 0 else 0
    ttft = prompt_eval_duration  # time to process prompt ≈ TTFT

    return {
        "label": label,
        "elapsed_s": round(elapsed, 3),
        "prompt_tokens": prompt_tokens,
        "completion_tokens": completion_tokens,
        "tokens_per_sec": round(tps, 1),
        "ttft_ms": round(ttft * 1000, 1),
    }


def benchmark_latency_sweep():
    prompt = "Write a short story about a robot."
    lengths = [32, 128, 512]

    print("\n=== Latency Sweep ===")
    results = []
    for n in lengths:
        r = benchmark_single(prompt, n, label=f"max_tokens={n}")
        results.append(r)
        print(f"  {r['label']:20s} | {r['elapsed_s']:6.2f}s | "
              f"{r['completion_tokens']:4d} tok | "
              f"{r['tokens_per_sec']:6.1f} tok/s | "
              f"TTFT: {r['ttft_ms']:.1f} ms")
    return results


def benchmark_concurrent(n_requests=5, max_tokens=128):
    prompt = "Explain quantum computing in simple terms."

    def do_request(i):
        return benchmark_single(prompt, max_tokens, label=f"req-{i+1}")

    print(f"\n=== Concurrent Benchmark ({n_requests} parallel) ===")
    start = time.perf_counter()
    with ThreadPoolExecutor(max_workers=n_requests) as executor:
        results = list(executor.map(do_request, range(n_requests)))
    total_elapsed = time.perf_counter() - start

    total_completions = sum(r["completion_tokens"] for r in results)
    print(f"  Wall time: {total_elapsed:.2f}s")
    print(f"  Total: {total_completions} tokens")
    print(f"  Aggregate: {total_completions / total_elapsed:.1f} tok/s")
    print(f"  Per-request avg: {statistics.mean(r['tokens_per_sec'] for r in results):.1f} tok/s")

    return {"wall_time_s": round(total_elapsed, 2), "results": results}


def main():
    print("=" * 55)
    print("  Ollama GPU Benchmark")
    print(f"  API: {API_BASE}")
    print(f"  Model: {MODEL}")
    print("=" * 55)

    if not check_server():
        print("Start ollama first: ollama serve")
        return

    latency_results = benchmark_latency_sweep()
    concurrent_results = benchmark_concurrent(n_requests=5, max_tokens=128)

    avg_tps = statistics.mean(r["tokens_per_sec"] for r in latency_results)
    avg_ttft = statistics.mean(r["ttft_ms"] for r in latency_results)

    print("\n" + "=" * 55)
    print("  SUMMARY")
    print("=" * 55)
    print(f"  Model: {MODEL} (Q4_K_M quantized)")
    print(f"  Avg throughput (single): {avg_tps:.1f} tok/s")
    print(f"  Avg TTFT: {avg_ttft:.1f} ms")
    print(f"  Concurrent throughput: {concurrent_results['wall_time_s']:.1f}s wall")
    print("\n  Tip: monitor GPU with `nvidia-smi` in another terminal")
    print("=" * 55)


if __name__ == "__main__":
    main()
