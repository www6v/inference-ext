# 问题与解决方案索引

> 最后更新：2026-11-13

## 问题列表

| # | 文件 | 问题 | 状态 |
|---|------|------|------|
| 01 | `01-github-timeout-solved.md` | GitHub 下载超时/失败 | ✅ 已解决 |
| 02 | `02-build-tools-missing.md` | 编译工具缺失 (CMake, Ninja) | ✅ 已解决 |
| 03 | `03-modelscope-incomplete-solved.md` | ModelScope 模型文件不完整 | ✅ 已解决 |
| 04 | `04-128k-context-remote-access.md` | 配置 128K 上下文 + 远程访问 | ✅ 已解决 |

---

## 快速参考

### 下载问题

**问题:** GitHub/HuggingFace 下载失败

**解决:**
- 使用 VPN 或代理
- 使用镜像站 `hf-mirror.com`
- 使用 ModelScope (部分文件不完整)

### 编译问题

**问题:** 缺少 CMake/Ninja 编译工具

**解决:**
- 使用预构建引擎包 (`--prebuilt`)
- 或安装编译工具: `pip install cmake ninja`

### 模型文件问题

**问题:** ModelScope 上 Coder 模型第2个分片 404

**解决:**
- 使用 `hf-mirror.com` 下载完整文件
- 文件路径: `IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-*.gguf`

### 上下文配置

**问题:** 默认 32K 上下文不够用

**解决:**
- 编辑 `strata-coder-iq1_m.json`
- 修改 `--max-context` 为 `131072` (128K)
- 重启服务

### 远程访问

**问题:** 服务默认只监听 127.0.0.1

**解决:**
- 启动时添加 `--host 0.0.0.0`
- 或使用 `./start.sh` (已配置)

---

## 当前部署状态

```
✅ 模型: Qwen3.8-Flash-Next Coder (IQ1_M)
✅ 上下文: 128K (131,072 tokens)
✅ 远程访问: http://192.168.3.4:8080
✅ 性能: 61.6 tok/s output, 96.3 tok/s prompt
```

---

## 相关文档

- `deploy/README.md` - 完整部署文档
- `deploy/QUICK-REFERENCE.md` - 快速参考
- `analysis/Strata支持的模型与上下文大小.md` - 模型与上下文详情
- `analysis/Strata项目分析报告.md` - 项目全面分析
- `analysis/Strata单 GPU 推理大模型技术方案.md` - 底层技术实现
