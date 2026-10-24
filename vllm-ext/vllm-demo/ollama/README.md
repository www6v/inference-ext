# Ollama GPU 推理

## 已验证模型

| 模型 | 大小 | GPU | 生成速度 |
|------|------|-----|---------|
| gemma4:26b (Q4_K_M) | 18 GB | 100% | ~130-150 tok/s |

## 运行

```bash
# 性能测试
python benchmark.py

# 手动推理
ollama run gemma4:27b "你好"

# API 调用
curl http://localhost:11434/api/generate -d '{
  "model": "gemma4:26b",
  "prompt": "Hello",
  "stream": false
}'
```

## Benchmark 结果（RTX 3090, gemma4:26b）

| 测试 | 生成速度 | TTFT |
|------|---------|------|
| 32 tokens | 145.2 tok/s | 1.8s |
| 128 tokens | 149.6 tok/s | 7.2s |
| 512 tokens | 85.7 tok/s | 6.1s |
| 平均单请求 | **126.8 tok/s** | 5.0s |
| 5 并发 | 17.1 tok/s 聚合 | - |

## GPU 修复

如果推理变慢（回退到 CPU），复制 CUDA DLL：

```powershell
copy "$env:LOCALAPPDATA\Programs\Ollama\lib\ollama\cuda_v13\*.dll" "$env:LOCALAPPDATA\Programs\Ollama\lib\ollama\"
# 然后重启 ollama
```
