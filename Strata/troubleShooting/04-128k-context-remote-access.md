# 问题: 配置 128K 上下文并启用远程访问

## 日期
2026-11-13

## 问题描述
1. 需要将默认 32K 上下文扩展为 128K
2. 服务默认监听 127.0.0.1，无法远程访问
3. Claude Code 73K 提示词超出 32K 上下文限制

## 解决方案

### 1. 配置 128K 上下文

**编辑配置文件:**
```bash
vi /home/wangwei/wei/workspacePy/infra-inference/Strata-main/strata-coder-iq1_m.json
```

**修改内容:**
```json
{
  "args": [
    ...
    "--max-context",
    "131072",  // 从 32768 改为 131072
    ...
  ]
}
```

**重启服务生效:**
```bash
./stop.sh && ./start.sh
```

### 2. 启用远程访问

**修改启动参数:**
```bash
--host 0.0.0.0  # 监听所有网络接口
```

**或使用远程启动脚本:**
```bash
./run-coder-iq1_m-remote.sh
```

### 3. 验证配置

```bash
curl http://192.168.3.4:8080/health
```

预期输出:
```json
{
  "status": "ok",
  "max_context": 131072,
  "model": "qwen3.8-flash-next-coder-iq1_m",
  ...
}
```

## 内存影响

| 上下文 | KV Cache | 总内存需求 |
|--------|----------|-----------|
| 32K | ~2 GB | ~32 GB |
| **128K** | **~8 GB** | **~38 GB** |

**本机配置:** 31 GB RAM + 24 GB VRAM = 55 GB 可用，128K 可以运行。

## 注意事项

1. **128K 在模型训练范围内** (≤262144)，不需要 rope scaling，质量最佳
2. **超过 262144 需要 rope scaling** (yarn 方法)，质量可能下降
3. **Claude Code 兼容性:** 73K < 128K，勉强可用，但长对话仍可能截断

## 状态
✅ 已解决 - 128K 上下文配置成功，远程访问正常

## 相关文件
- `deploy/README.md` - 部署文档
- `deploy/start.sh` - 启动脚本
- `deploy/stop.sh` - 停止脚本
- `analysis/Strata支持的模型与上下文大小.md` - 模型与上下文文档
