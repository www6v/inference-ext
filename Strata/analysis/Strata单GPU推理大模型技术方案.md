# Strata 单 GPU 推理大尺寸 LLM 技术方案深度解析

> 分析日期：2026-11-12
> 源码路径：`Strata-main/`
> 分析基础：项目报告第十二节「核心技术特性」

---

## 目录

- [核心问题](#核心问题)
- [总体架构](#总体架构)
- [一、Doorbell 协议：CPU-GPU 重叠执行](#一doorbell-协议cigpu-重叠执行)
  - [1.1 核心思想](#11-核心思想)
  - [1.2 Doorbell 数据结构](#12-doorbell-数据结构)
  - [1.3 协议流程](#13-协议流程)
  - [1.4 关键实现细节](#14-关键实现细节)
- [二、Expert Cache：VRAM 驻留分层](#二expert-cachevram-驻留分层)
  - [2.1 三级 Expert 存储](#21-三级-expert-存储)
  - [2.2 Expert Cache 核心设计](#22-expert-cache-核心设计)
  - [2.3 为什么没有驱逐策略？](#23-为什么没有驱逐策略)
  - [2.4 每层独立准入（解决缓存垄断）](#24-每层独立准入解决缓存垄断)
  - [2.5 弹性 VRAM（--vram-elastic）](#25-弹性-vram--vram-elastic)
- [三、CUDA Graph 捕获：消除 Kernel Launch 开销](#三cuda-graph-捕获消除-kernel-launch-开销)
  - [3.1 问题](#31-问题)
  - [3.2 解决方案](#32-解决方案)
  - [3.3 关键约束](#33-关键约束)
  - [3.4 实测效果](#34-实测效果)
- [四、VMM 弹性 KV Cache](#四vmm-弹性-kv-cache)
  - [4.1 CUDA Virtual Memory Management](#41-cuda-virtual-memory-management)
  - [4.2 为什么用 VMM？](#42-为什么用-vmm)
- [五、分页 KV Cache + 主机常驻溢出](#五分页-kv-cache--主机常驻溢出)
  - [5.1 架构](#51-架构)
  - [5.2 KV 解析流程](#52-kv-解析流程)
  - [5.3 支持的 KV 格式](#53-支持的-kv-格式)
- [六、内存规划：VRAM 预算方程](#六内存规划vram-预算方程)
  - [6.1 预算计算](#61-预算计算)
  - [6.2 GDN 状态开销](#62-gdn-状态开销)
  - [6.3 关键设计原则](#63-关键设计原则)
- [七、CPU Expert Pool](#七cpu-expert-pool)
  - [7.1 架构](#71-架构)
  - [7.2 Expert Job 结构](#72-expert-job-结构)
  - [7.3 无锁工作窃取](#73-无锁工作窃取)
  - [7.4 CPU Expert Kernel](#74-cpu-expert-kernel)
  - [7.5 实测性能](#75-实测性能)
- [八、Pinned Arena & 大页优化](#八pinned-arena--大页优化)
  - [8.1 问题](#81-问题)
  - [8.2 解决方案：大页](#82-解决方案大页)
  - [8.3 实测对比](#83-实测对比)
- [九、DeviceArena：Bump 分配器](#九devicearenabump-分配器)
- [十、MoE 路由机制](#十moe-路由机制)
  - [10.1 路由流程](#101-路由流程)
  - [10.2 BF16 精度至关重要](#102-bf16-精度至关重要)
- [十一、推测解码：减少生成步数](#十一推测解码减少生成步数)
  - [11.1 两种 Drafting 策略](#111-两种-drafting-策略)
  - [11.2 Speculative Controller](#112-speculative-controller)
  - [11.3 MTP Draft Layer](#113-mtp-draft-layer)
  - [11.4 Suffix Drafter 匹配桶](#114-suffix-drafter-匹配桶)
- [十二、DSpark：DeepSeek 专用推测解码](#十二dsparkdeepseek-专用推测解码)
  - [12.1 架构](#121-架构)
  - [12.2 Draft-Verify 循环](#122-draft-verify-循环)
  - [12.3 Expert 数量优化](#123-expert-数量优化)
- [十三、PCIe Expert 流式传输（DeepSeek）](#十三pcie-expert-流式传输deepseek)
  - [13.1 PCIe Lane 架构](#131-pcie-lane-架构)
  - [13.2 Stream Fetch Kernel](#132-stream-fetch-kernel)
- [十四、Expert Profile：路由频率追踪](#十四expert-profile路由频率追踪)
- [十五、对话缓存](#十五对话缓存)
- [十六、配置参数速查](#十六配置参数速查)
- [十七、端到端 Token 生成路径](#十七端到端-token-生成路径)
- [十八、实测性能数据](#十八实测性能数据)
  - [Qwen3.8-Flash-Next Q2_0（RTX 5070 12GB, Ryzen 5 7600）](#qwen38-flash-next-q2_0rtx-5070-12gb-ryzen-5-7600)
  - [关键延迟指标](#关键延迟指标)
- [总结：为什么能在单 GPU 上运行大 LLM](#总结为什么能在单-gpu-上运行大-llm)

---

## 核心问题

以 Qwen3.8-Flash-Next 为例：

| 资源 | 大小 |
|------|------|
| Expert 权重 | **33.97 GB** |
| Dense 权重 | ~2 GB |
| KV Cache (32K) | ~2 GB |
| GDN 循环状态 | ~118 MB |
| **消费级 GPU VRAM** | **12-24 GB** |

**33.97 GB 的 expert 权重 + 其他开销远超单卡 VRAM**。Strata 的解决方案是一套完整的分层内存 + CPU-GPU 协同计算架构。

---

## 总体架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      单 GPU（12 GB VRAM）                                │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────────────┐ │
│  │ Dense 权重    │  │ KV Cache     │  │ Expert Cache（弹性）            │ │
│  │ （固定 ~2GB）  │  │ （弹性 ~2GB） │  │ 4000+ slots（~4-6 GB）         │ │
│  └──────────────┘  └──────────────┘  └────────────────────────────────┘ │
│                                                                         │
│  CUDA Graph 捕获 replay · Doorbell 协议 · VMM 弹性内存                    │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │
              Mapped Pinned Memory（Doorbell + PCIe 零拷贝）
                               │
┌──────────────────────────────┴──────────────────────────────────────────┐
│                      主机 DRAM（64+ GB）                                 │
│                                                                         │
│  ┌────────────────────┐  ┌─────────────────────────────────────────────┐│
│  │ Pinned Arena       │  │ CPU Expert Pool                             ││
│  │ 33.97 GB experts   │  │ 每物理核一个 worker，~42 GB/s DRAM 带宽       ││
│  │ 大页 2MB / 4KB     │  │ 计算 GPU cache miss 的 expert                 ││
│  │ cudaHostRegister   │  │ AVX-512 VNNI 2-bit 量化 expert kernel        ││
│  └────────────────────┘  └─────────────────────────────────────────────┘│
│                                                                         │
│  ┌────────────────────┐                                                │
│  │ SSD（可选）         │  DirectFile O_DIRECT 异步 I/O                    │
│  │ experts.bin 34GB   │  n-gram 表 26.8 GiB                             │
│  └────────────────────┘                                                │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 一、Doorbell 协议：CPU-GPU 重叠执行

### 1.1 核心思想

MoE 模型的 expert 计算是整个推理中唯一不能全部放在 VRAM 的部分。Strata 将 MoE 层**在路由器处一分为二**，让 GPU 和 CPU 并行工作：

```
时间线（一层）：
─────────────────────────────────────────────────────────────────────→

GPU:    [attn → mixer → gr_write → ffn_gr_read → moe_route]
                                                        ↓ 敲响 Doorbell
GPU hits:                                [VRAM 中的 expert 计算]
                                                        ↓
CPU:                                     [pool: 计算 cache miss 的 expert]
                                                        ↓ copy H2D
GPU:    [moe_finish (combine hits + misses) → gr_write]
          ↓
GPU:    [下一层 pre...]                                       ← 层间重叠
```

**关键**：CPU 获得约 **29% 层执行时间** 来计算 expert 输出，几乎完全隐藏了 CPU 端的工作延迟。

### 1.2 Doorbell 数据结构

```cpp
// include/strata/core/layer.hpp (lines 407-441)
struct Doorbell {
    // HOST 视角（mapped pinned memory）
    float* h_x_f = nullptr;        // 输入激活值
    int32_t* h_ids = nullptr;      // Router 选出的 expert ID
    float* h_weights = nullptr;    // Router 权重
    uint32_t* h_seq = nullptr;     // 序列号（ring bell）
    uint32_t* h_flag = nullptr;    // Host 响应标志

    // DEVICE 视角（同一块物理内存）
    float* d_x_f;
    int32_t* d_ids;
    float* d_weights;
    uint32_t* d_seq;
    uint32_t* d_flag;
};
```

### 1.3 协议流程

```cpp
// src/core/session.cpp (lines 590-798) 核心循环

for (int64_t l = 0; l < g.n_layers; ++l) {
    // 1. 轮询 GPU 的 doorbell（volatile 读 mapped memory）
    volatile uint32_t* const seq = s.db->h_seq;
    while (*seq < want) {
        cudaEventQuery(probe);    // 必须调用！刷提交队列
        STRATA_SPIN_PAUSE();
    }

    // 2. GPU 命中的 expert 开始异步计算
    if (hits != nullptr) hits(user, cs, HitPhase::Launch, ...);

    // 3. CPU pool 计算 miss 的 expert
    pool(user, s.db->h_x_f, s.db->h_ids, s.db->h_weights,
         g.n_embd, k, y_miss);

    // 4. 拷贝 CPU 结果到设备（stream-ordered）
    cudaMemcpyAsync(gr.parts_dev, y_miss, parts_bytes,
                    cudaMemcpyHostToDevice, cs);

    // 5. 合并 GPU hits 和 CPU misses
    if (hits != nullptr) hits(user, cs, HitPhase::Combine, nullptr, 0);

    // 6. 执行本层 post-processing
    cudaGraphLaunch(gr.posts[l], cs);

    // 7. 启动下一层 pre-processing（重叠！）
    if (l + 1 < g.n_layers) {
        cudaGraphLaunch(gr.execs[l + 1], cs);
    }
}
```

### 1.4 关键实现细节

**为什么必须用 `cudaEventQuery` 而非纯内存轮询？**
> Windows 驱动批量提交命令。纯内存自旋在 Windows 上**永远无法运行 kernel**：实测 500ms 内 5,907,703 次自旋，kernel 从未执行。

**SYCL 后端的 Doorbell**（Intel Arc）：
```cpp
// sycl/include/strata/sycl_doorbell.hpp
// 未缓存 L1+L3 写入绕过 GPU 缓存
using doorbell_uncached_write = decltype(sycl::ext::oneapi::experimental::properties(
    sycl::ext::intel::experimental::write_hint<...uncached...>));

// Arc GPU 的系统级原子存储会从缓存中服务，直到 kernel 结束才到达主机
// 未缓存写入提示立即到达内存
inline void sys_store(volatile uint32_t* p, uint32_t v) {
    sycl::ext::oneapi::experimental::annotated_ptr<uint32_t, doorbell_uncached_write> u(p);
    u[0] = v;
    sycl::atomic_fence(sycl::memory_order::release, sycl::memory_scope::system);
}
```

---

## 二、Expert Cache：VRAM 驻留分层

### 2.1 三级 Expert 存储

| 层级 | 位置 | 容量 | 访问延迟 |
|------|------|------|----------|
| **VRAM Tier** | GPU 显存 | ~4000+ slots（~5.5 GB） | ~0 ns（GPU 直接访问） |
| **RAM Tier** | Pinned DRAM | 全部 33.97 GB | ~PCIe 带宽（~42 GB/s） |
| **File Tier** | SSD mmap | 磁盘文件 | 页缺失 = 磁盘读取 |

每个 expert slot 大小：**1,382,400 bytes**（gate_up + down 矩阵，含 codes 和 scales）。

### 2.2 Expert Cache 核心设计

```cpp
// include/strata/core/expert_cache.hpp

class ExpertCache {
    // 驻留表：(layer, expert) -> slot 或 kNotResident (-1)
    int32_t slot_of(int64_t layer, int64_t expert) const;

    // 准入一个新 expert —— 无驱逐（刻意设计）
    int32_t admit(int64_t layer, int64_t expert);

    // 每层独立准入范围
    // 层 l 只能使用 slot [l*q, (l+1)*q)，q = slots()/n_layers
    void layer_slot_range(int64_t layer, int64_t& lo, int64_t& hi) const;
};
```

### 2.3 为什么没有驱逐策略？

> "It never evicts, because eviction policy is a measured question (R4.1's LFU-decay vs LRU sweep) and a placeholder policy would set the hit rate that everything downstream is then sized against."

驱逐策略是一个需要实测的问题（LFU-decay vs LRU sweep），一个占位策略会污染下游所有尺寸调整的命中率基准。

### 2.4 每层独立准入（解决缓存垄断）

**问题**：全局准入模式下，位置 0 的前 26 层会占满全部缓存，永不更换。

**解决**（R4.2g）：
```cpp
// 层 l 只能使用 [l*q, (l+1)*q) 范围的 slot
// q = total_slots / n_layers
// 这确保每层公平分享缓存空间
void layer_slot_range(int64_t layer, int64_t& lo, int64_t& hi) const;
```

实测效果：全局形式命中率仅 2.97%；per-layer 准入后命中率显著提升。

### 2.5 弹性 VRAM（--vram-elastic）

```cpp
// src/core/expert_cache.cpp (lines 410-560)
// 使用 CUDA VMM 分段竞技场

bool ExpertCache::open_segmented(uint64_t want, std::string& err);

// 运行时收缩/增长，地址保持稳定（CUDA graph 仍然有效）
bool shrink(int64_t keep_bytes, std::string& err);  // 归还 VRAM
bool grow(int64_t want_bytes, std::string& err);    // 重新获取 VRAM
```

Expert cache 和 KV cache 动态共享 VRAM：
- 长上下文时：expert cache `shrink()` → KV cache `map_range()` 获取 VRAM
- 短上下文时：expert cache `grow()` 获取更多 VRAM 用于缓存 expert

---

## 三、CUDA Graph 捕获：消除 Kernel Launch 开销

### 3.1 问题

一层有 ~8 次 kernel 提交，每次驱动调用开销 10-22 μs，一层 ~0.1 ms 往返。48 层 × 多 token = 大量 CPU 开销。

### 3.2 解决方案

```cpp
// include/strata/core/graph.hpp

class CapturedGraph {
    bool begin(void* stream, std::string& err);   // 开始录制
    bool end(void* stream, std::string& err);     // 停止，实例化
    bool launch(void* stream, std::string& err) const;  // 回放
};

class GraphRegistry {
    // 按 (layer_type, n_tokens) 键缓存
    bool record(LayerType type, int n_tokens,
                const std::function<void()>& body, std::string& err);
};
```

每层捕获两个 graph：
- `pre[l]`：从 embed 到 router（doorbell 之前）
- `post[l]`：从 moe_finish 到 gr_write

### 3.3 关键约束

1. **"Graph 在回放时重读输入缓冲区，但不重读 kernel 参数"** — 每步变化的量必须是设备缓冲区中的 DATA，不能是 kernel argument
2. **"固定地址是调用者的责任"** — 所有缓冲区必须在捕获前分配
3. **"等待必须轮询驱动，不是内存"** — Windows 上纯内存自旋永远无法运行 kernel

### 3.4 实测效果

- 从 ~2000 次 kernel launch → 48 次 graph launch
- **加速比 1.51x**（来自 graph replay）

---

## 四、VMM 弹性 KV Cache

### 4.1 CUDA Virtual Memory Management

```cpp
// include/strata/core/vmm.hpp

class VmmRange {
    // 保留地址范围，不映射物理内存
    bool reserve(uint64_t bytes);

    // 映射 chunk [lo, hi) 到物理内存
    template <class Take> bool map_range(int64_t lo, int64_t hi, Take take);

    // 解映射并返回物理 chunk
    VmmChunk unmap(int64_t i);
};
```

底层 API：
- CUDA: `cuMemAddressReserve` / `cuMemCreate` / `cuMemMap` / `cuMemSetAccess`
- HIP: `hipMemAddressReserve` / `hipMemCreate` / `hipMemMap`
- 粒度：2 MiB chunks

### 4.2 为什么用 VMM？

| 需求 | VMM 如何解决 |
|------|-------------|
| KV cache 随上下文增长 | 地址预分配，物理页按需映射 |
| CUDA graph 地址不能变 | 地址固定，只映射/解映射物理页 |
| 与 expert cache 共享 VRAM | Expert cache shrink → KV cache map |
| 不浪费 VRAM | 只为实际使用的上下文分配物理内存 |

---

## 五、分页 KV Cache + 主机常驻溢出

### 5.1 架构

```cpp
// include/strata/kernels/kv_stream.hpp

// 主机副本：权威 K/V 存在 device-mapped pinned memory
struct KvHostPools {
    uint16_t* k_pool = nullptr;   // fp16 模式
    int8_t* k_q = nullptr;        // int8 模式：codes
    uint16_t* k_scale = nullptr;  // fp16 scale（每 64 值一组）
    uint8_t* k_q4 = nullptr;     // q4_0 模式
    // ... V 同理
};

// 流式层的驻留映射
struct KvStreamMap {
    int32_t* page_table = nullptr;   // block -> slot，或 -1（miss）
    int32_t* slot_block = nullptr;   // slot -> block
    int32_t* slot_stamp = nullptr;   // resolve epoch
    int32_t* slot_ref = nullptr;     // clock 引用位
};
```

### 5.2 KV 解析流程

1. 1024 线程的 block 遍历选中的 attention ID
2. 驻留 block 设置 epoch 戳和引用位
3. 缺失 block 通过 **CLOCK sweep**（二次机会驱逐）抢占 victim slot
4. 拷贝 kernel 通过 PCIe 从主机副本读取缺失 block（UVA 零拷贝）

### 5.3 支持的 KV 格式

| 格式 | 精度 | 每 token 大小 |
|------|------|---------------|
| `kKvF16` | FP16 全精度 | 最大 |
| `kKvInt8` | INT8 codes + FP16 scales (grouped-64) | 中等 |
| `kKvQ4` | Q4_0 量化 | 最小 |
| `kKvHybrid` | K=INT8, V=rotated Q4_0 | 折中 |

**激活**：`--kv-resident N` 保持每个 QSA 层 N 个 cell 在 VRAM，其余在主机内存。

---

## 六、内存规划：VRAM 预算方程

### 6.1 预算计算

```cpp
// include/strata/plan/plan.hpp

struct Plan {
    uint64_t max_context = 0;
    uint64_t kv_bytes = 0;       // KV + indexer keys @ max_context
    uint64_t state_bytes = 0;    // GDN 循环状态 + conv 历史（不可驱逐）
    uint64_t cache_bytes = 0;    // 剩余给 expert cache slot
    uint64_t cache_slots = 0;
    uint64_t vram_budget = 0;
    uint64_t dram_experts = 0;   // 全部 expert 权重，从 DRAM 流式读取
};
```

**VRAM 池**：
```cpp
inline uint64_t vram_pool_bytes() {
    return 5943000000ull;  // ~5.95 GB
}
```

**预算方程**：
```
cache_bytes = vram_pool - kv_bytes - fixed_costs

fixed_costs = dense_bytes + embd_bytes + mtp_bytes + workspace_bytes + state_bytes

cache_slots = cache_bytes / 1,382,400  （每个 expert slot 的大小）
```

### 6.2 GDN 状态开销

每个 GDN 层（共 36 层）：
```
recurrence: (S, h_v, S) fp32 = 128 × 48 × 128 × 4 = 3,145,728 B
conv history: (d_conv-1, C) fp32 = 3 × 10240 × 4 = 122,880 B
────────────────────────────────────────────
36 层合计 ≈ 117.7 MB ≈ 85 个 expert cache slot
```

### 6.3 关键设计原则

> "The engine has 33.97 GB of expert weights (has to live in DRAM and be streamed) and a fixed VRAM budget that has to hold the dense weights, the KV cache, the indexer keys, the recurrent state and as many expert-cache slots as remain."

> "If p.kv_bytes + fixed > pool, throw DoesNotClose — refuse rather than overcommit."

---

## 七、CPU Expert Pool

### 7.1 架构

```cpp
// include/strata/kernels/cpu/pool.hpp

class ExpertPool {
    // 每个物理核一个 worker（不用 SMT 兄弟）
    explicit ExpertPool(int n_workers = 0, bool pin = true,
                        bool host_works = true, ...);

    void run(ExpertJob* jobs, int n);         // 阻塞直到完成
    void run_split(ExpertJob* jobs, int n);   // expert 按行切分到所有线程
};
```

### 7.2 Expert Job 结构

```cpp
struct ExpertJob {
    const uint8_t* blob = nullptr;   // 一个 1,382,400 字节的 expert
    const ActQ* act = nullptr;       // 层的量化激活（batch 内共享）
    float* out = nullptr;            // 输出缓冲
    float weight = 1.0f;             // Router 权重（HOST 端应用，非 kernel）
};
```

### 7.3 无锁工作窃取

```cpp
// 每个原子量独占缓存行 —— 无伪共享
alignas(64) std::atomic<uint64_t> head_{0};   // epoch | njobs | index
alignas(64) std::atomic<uint32_t> done_{0};
alignas(64) std::atomic<uint32_t> parked_{0};
alignas(64) std::atomic<uint32_t> epoch_{0};
```

### 7.4 CPU Expert Kernel

使用 **AVX-512 VNNI** 指令处理 2-bit 量化 expert（Q2_0）：
- `unpack64_q2_0()`：VPMULTISHIFTQB 进行 2-bit 解包
- `block_dot()`：VNNI dpbusd 进行 int8 点积
- 512-bit lane 最大化吞吐

### 7.5 实测性能

| 指标 | 数值 |
|------|------|
| Pool 带宽 | ~42 GB/s（6 核，DRAM 受限） |
| 每 expert（~1.38 MB） | ~0.33 ms |
| 10 experts/token | ~3.3 ms CPU 时间 |
| 55% VRAM 命中率 | ~1.5 ms 平均 |

---

## 八、Pinned Arena & 大页优化

### 8.1 问题

```
33.97 GB / 4 KB 页 = 830 万 TLB 条目
→ 放不下任何 TLB
→ 每次 expert matvec 的每个 block 都 TLB miss
```

### 8.2 解决方案：大页

```cpp
// include/strata/core/pinned.hpp

struct PinnedArena {
    void* base = nullptr;
    uint64_t capacity = 0;
    PageBacking backing = PageBacking::NormalPages;  // 或 LargePages

    // WDDM 兼容：当整个竞技场无法注册时，分片注册
    uint64_t registered_bytes = 0;
    uint64_t slice_bytes = 0;
};

enum class PageBacking {
    LargePages,    // 2 MB 页 → 17K TLB 条目 ✓
    NormalPages,   // 4 KB 页
    PinnedByCuda   // cudaHostRegister
};
```

**大页实现**：
- Linux：`mmap(MAP_HUGETLB)` / hugetlbfs
- Windows：`VirtualAlloc(MEM_LARGE_PAGES)`（需 SeLockMemoryPrivilege）

### 8.3 实测对比

| 方案 | 带宽 |
|------|------|
| Pinned Arena（大页） | ~42.8 GB/s |
| mmap（普通页） | ~19 GB/s |

差距来自文件页被 OS 驱逐。

---

## 九、DeviceArena：Bump 分配器

```cpp
// include/strata/core/device.hpp

class DeviceArena {
    // 每次 planner region 一次 cudaMalloc，bump 子分配，NO FREES
    void* alloc(uint64_t bytes, uint64_t align = 256);

    uint64_t capacity() const { return capacity_; }
    uint64_t used() const { return used_; }
    uint64_t peak() const { return used_; }  // 无 free，used 即 peak
};
```

**为什么不用通用分配器？**
> "Memory plan is fixed at startup. A freeing allocator would be solving a problem the engine does not have while adding fragmentation and failure modes it does not need."

内存计划在启动时固定，所有 region 和大小在分配前已知。带 free 的分配器只会增加碎片化和失败模式。

---

## 十、MoE 路由机制

### 10.1 路由流程

```cpp
// include/strata/kernels/router_top10.hpp, src/core/layer.cpp

bool moe_route(const WeightTable& tables, const ModelGeometry& g,
               int64_t layer, int64_t k,
               const MoEBuffers& b, const float* x,
               void* stream, std::string& err, const Doorbell* db);
```

路由语义（来自 `ref/moe.py::router`）：
1. **Softmax** 在所有 512 个 expert 上
2. **稳定降序 argsort**（相同值按下标打破）
3. **Gather** top-k expert（k=10）
4. **归一化**，ggml 2^-14 下钳位

### 10.2 BF16 精度至关重要

```cpp
// Router 权重是 BF16，必须用 bf16_gemv
// 用 fp16 激活会导致 8.1e-3 误差 → 翻转 top-10 选择 → 路由到完全不同的 expert

project_bf16(x, b.x_bf16, (const uint16_t*) w_router->data,
             b.logits, g.n_embd, g.n_expert, true, stream);

// 原生融合 router（仅支持 512×10 规范配置）
if (native_router_enabled() && g.n_expert == 512 && k == 10) {
    native_router_top10(b.logits, b.ids, b.weights, stream);
}
```

---

## 十一、推测解码：减少生成步数

### 11.1 两种 Drafting 策略

| 策略 | 机制 | VRAM 开销 |
|------|------|-----------|
| **Suffix lookup** | 从对话历史 N-gram 匹配 | ~0 |
| **MTP** | 模型自身的 draft head | ~0.9 GB |

### 11.2 Speculative Controller

```cpp
// include/strata/spec/controller.hpp

struct CostModel {
    double dense_ms = 11.0;           // 单 token dense pass
    double cpu_all_miss_ms = 15.8;    // 480 experts 全在 CPU
    double hit_rate = 0.55;           // VRAM expert cache 命中率
    double mtp_draft_ms = 1.2;        // 每 MTP draft token
};

class Controller {
    Choice choose(int lookup_available, int lookup_match,
                  bool mtp_ready) const;
    void observe(const Choice& c, int accepted, int lookup_match);
};
```

控制器最大化 **E[tokens committed] / T(step)**，使用 EMA 接受率自适应。

### 11.3 MTP Draft Layer

```cpp
// include/strata/core/mtp.hpp
// 模型最后一层的完整副本，训练用于预测未来 token

// 架构：
// e = fc_embedding(rms(embed(tok)) * (1+w))
// h = fc_hidden per_stream(rms_10240(R) * (1+w))
// R = h + e → attention hyper-connection → QSA attention → MLP → MoE (512 experts, top-10)
// → final mixer → head

// 关键属性：
// - 全部 512 routed expert 在 VRAM（708 MB）
// - Q8_0 量化投影
// - Attention 是 DENSE（不像主模型的 sparse indexer）
// - 接受率：0.89 / 0.86 / 0.85（step 1-3）
```

### 11.4 Suffix Drafter 匹配桶

```cpp
// 匹配长度影响接受概率
bucket(0-4 tokens):   q = 0.35
bucket(5-7 tokens):   q = 0.60
bucket(8-15 tokens):  q = 0.80
bucket(16+ tokens):   q = 0.92
```

---

## 十二、DSpark：DeepSeek 专用推测解码

### 12.1 架构

```cpp
// src/dsv41/ds4_model.hpp

struct Options {
    bool dspark_auto = true;    // 仅在有足够 GPU 的层加载 drafter
    bool dspark = true;         // 加载 DSpark drafter（mtp.* blocks）
    int dspark_block = 0;       // 每轮最大 draft 数
    float dspark_conf = 0.5f;   // 置信度 >= 此值才验证 draft
};
```

### 12.2 Draft-Verify 循环

```cpp
// src/dsv41/ds4_main.cpp

bool round(Model& m, int tok, int room, bool spec, float conf_min, ...) {
    if (spec && room > 1 && m.draft_block() > 0) {
        // Draft 阶段
        m.draft(tok, drafts, conf, err, ...);

        // 累积置信度截断
        float cum = 1.0f;
        while (keep < drafts.size()
               && conf[keep] >= conf_min
               && (cum *= conf[keep]) >= cum_min)
            ++keep;

        if (keep > 0) {
            // Verify 阶段
            m.verify(tok, drafts, ..., acc, next, err);
        }
    }
}
```

**累积置信度截断**（`dspark_cum`）：
- 当 P(所有保留 draft) < 阈值时停止
- RDNA4 默认 0.5，其他 0.0
- 防止低置信度位置过度 draft

### 12.3 Expert 数量优化

```cpp
// src/dsv41/ds4_experts_rule.hpp
// 小 VRAM 系统减少每 token 使用的 expert 数

// 模型用 6 experts → 减到 5 experts
// VRAM <= 16GB 或集成 GPU 或 RDNA4 时自动启用

// 实测（1x R9700, 2.25 bpw）：
// 5 vs 6 experts: decode +16%, agent loop -24% wall time
// KL divergence vs original: 0.030（质量损失可接受）
```

---

## 十三、PCIe Expert 流式传输（DeepSeek）

### 13.1 PCIe Lane 架构

```cpp
// src/dsv41/ds4_pcie.hpp

struct Costs {
    double c = 0, oc = 0;   // CPU lane: 每 expert, 每调用
    double p = 0, op = 0;   // Stream lane: 每 expert, 每请求
    double g = 0;            // GPU: 每 streamed expert
    double disk = 0;         // 磁盘读取时间
};

// 分流优化：哪些 expert 走 PCIe 流式 vs CPU 计算
unsigned split(const Costs& k, int n, unsigned cold, int max_s, double* t);

struct Pull {
    unsigned seq, done;
    unsigned long long src[kSlots];   // pinned expert 的设备地址
    unsigned ready[kSlots][4];         // 每矩阵就绪标志
};
```

### 13.2 Stream Fetch Kernel

```cpp
// GPU 从 pinned memory 拉取 expert

__global__ void stream_fetch_kernel(Pull* p, unsigned seq, ...) {
    // Block 0 thread 0 轮询主机标志
    // 每个流式 pick 的矩阵从 pinned memory 拷贝到 staging slot
    for (int i = 0; i < k; ++i) {
        for (int r = 0; r < 3; ++r) {  // gate, up, down 矩阵
            while (vp->ready[i][r] != seq) pull_nap();
            // 从 pinned memory 拷贝到 VRAM slot
            for (size_t j = ...; j < n16; j += gridDim.x * blockDim.x)
                dst[j] = src[j];
        }
    }
}
```

**参数**：
- `kSlots = 16`：每窗口最大流式 expert 数
- `kPullEnt = 128`：窗口条目（16 tokens × 8 picks）

---

## 十四、Expert Profile：路由频率追踪

```
文件：expert-profile.bin
格式：u32 计数数组，每层 n_exp 行
更新：推理过程中追踪路由计数
```

用于将最热的 expert 放入 VRAM cache。支持自适应交换：
- `--adapt-every N`：每 N 个窗口交换
- `--adapt-swaps N`：每窗口最大交换数
- `--adapt-decay F`：历史计数的衰减因子

---

## 十五、对话缓存

```cpp
// include/strata/core/conversation_cache.hpp

class ConversationCache {
    // 预算（字节）、slot 数、最小 token 数
    ConversationCache(size_t budget, size_t slots, int64_t min_tokens = 0);

    // 找到最佳匹配前缀
    Match best(const vector<Token>& prompt, ...) const;

    // 驱逐：最老优先，尊重共享前缀
    bool evict_oldest();

    // K/V 跨停车复用
    void retain(vector<ConversationKv>&& kv, int64_t tokens, ...);
};
```

自动大小计算：
```cpp
// 可用内存的 40%，上限 8 GiB
int64_t mib = usable * 2 / 5;
if (mib > 8192) mib = 8192;
```

---

## 十六、配置参数速查

| 参数 | 用途 |
|------|------|
| `--kv-grow` | VMM 弹性 KV cache |
| `--kv-resident N` | KV 流式：每层 N cell 在 VRAM |
| `--vram-elastic` | 分段 expert cache，可收缩/增长 |
| `--expert-cache N` | VRAM expert slot 数（auto = 计算） |
| `--vram-reserve-mib N` | 加载后保留的 VRAM |
| `--max-context N` | 规划的最大上下文长度 |
| `--memory-limit-mib N` | 容器环境的 RAM 上限 |
| `--resident-budget-gib N` | CPU-lane expert 预算 |
| `--mmap-experts` | 从 SSD mmap expert |
| `--adapt-every N` | 自适应 expert 交换间隔 |
| `--spec K` | 推测解码 draft token 数 |
| `--spec-min-p P` | 推测解码最小接受概率 |

---

## 十七、端到端 Token 生成路径

```
1. GPU 启动第 L 层 pre-processing（CUDA graph replay）
                ↓
2. GPU 敲响 Doorbell — 发布激活值 + 路由信息到 mapped memory
                ↓
3. CPU 看到 Doorbell（volatile 读），开始计算 miss 的 expert
                ↓
4. GPU 计算 VRAM 驻留 expert（hits），与 CPU 并行
                ↓
5. CPU 完成，cudaMemcpyAsync 拷贝结果到设备
                ↓
6. GPU 合并 hits + misses，执行第 L 层 post-processing
                ↓
7. GPU 启动第 L+1 层 pre-processing（与第 L 层 post 重叠）
                ↓
8. 48 层完成后 → LM Head → Sampling → 输出 token
```

---

## 十八、实测性能数据

### Qwen3.8-Flash-Next Q2_0（RTX 5070 12GB, Ryzen 5 7600）

| 场景 | Prompt 速度 | Output 速度 |
|------|------------|-------------|
| 1K 上下文 | 536 tok/s | 87.3 tok/s |
| 32K 上下文 | 2171 tok/s | 81.8 tok/s |
| 262K 上下文 | 1304 tok/s | 60.3 tok/s |

### 关键延迟指标

| 指标 | 数值 |
|------|------|
| VRAM Pool | ~5.95 GB |
| Expert blob 大小 | 1,382,400 bytes |
| CPU pool 带宽 | ~33-44 GB/s（DRAM 受限） |
| CUDA graph 节省 | ~0.1 ms/层（8 kernel launch） |
| Doorbell 延迟 | ~5.2 μs/次握手 |
| VRAM expert cache 命中率 | ~55% |
| MTP 接受率 | ~86%/position |

---

## 总结：为什么能在单 GPU 上运行大 LLM

Strata 的核心创新在于**将 VRAM 限制从硬约束转化为可管理的流式问题**：

1. **MoE 架构天然适配**：512 expert 中每 token 只用 10 个，大部分 expert 不需要同时在 VRAM
2. **Doorbell 协议**：CPU-GPU 重叠执行，~29% 层时间用于 CPU 计算 miss expert，几乎零延迟惩罚
3. **弹性 VRAM 共享**：KV cache 和 expert cache 通过 VMM 动态争夺 VRAM，地址稳定保证 CUDA graph 有效
4. **CUDA Graph 捕获**：消除 2000+ kernel launch 开销，1.51x 加速
5. **大页内存**：解决 830 万 TLB 条目问题，带宽翻倍（19→42 GB/s）
6. **推测解码**：MTP/Suffix drafting 减少实际生成步数
7. **分层 Expert 存储**：VRAM → Pinned DRAM → SSD，按需流式加载

最终效果：**33.97 GB 的 expert 权重在 12 GB GPU 上以 ~87 tok/s 的速度运行**。

---

*本分析基于 Strata 源码静态分析，重点解读项目报告中第十二节「核心技术特性」的底层实现机制。*
