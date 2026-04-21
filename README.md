# Scripts 使用说明

本目录包含 **Skills Markdown** 与 **MCP JSON 定义**之间的双向同步工具。

## 目录映射关系

```
tools/mcp/mcp_definitions/{domain}/{tool_name}.json
        ↕ 双向同步
skills/{domain}/{tool_name}.md
```

## 脚本说明

### 1. `generate_skills_from_json.py` — JSON → MD 生成

从 `tools/mcp/mcp_definitions/` 下的 JSON 定义文件，批量生成 `skills/` 目录下的 Markdown 文件。

**用法：**

```bash
# 首次生成（已存在的 md 文件会跳过）
python3 scripts/generate_skills_from_json.py

# 覆盖已有文件重新生成
python3 scripts/generate_skills_from_json.py --overwrite

# 预览模式，仅打印将要生成的文件，不实际写入
python3 scripts/generate_skills_from_json.py --dry-run

# 自定义输入/输出目录
python3 scripts/generate_skills_from_json.py --json-dir path/to/json --skills-dir path/to/skills
```

**参数：**

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--json-dir` | JSON 定义文件目录 | `tools/mcp/mcp_definitions` |
| `--skills-dir` | MD 文件输出目录 | `skills` |
| `--overwrite` | 覆盖已存在的 md 文件 | 否（默认跳过已有文件） |
| `--dry-run` | 仅打印，不实际写入 | 否 |

---

### 2. `sync_skills_to_json.py` — MD → JSON 回写

将 `skills/` 下 Markdown 文件的修改同步回 `tools/mcp/mcp_definitions/` 下的 JSON 文件。

**用法：**

```bash
# 预览模式，查看哪些文件有差异（推荐先执行）
python3 scripts/sync_skills_to_json.py --dry-run

# 执行回写
python3 scripts/sync_skills_to_json.py

# 自定义目录
python3 scripts/sync_skills_to_json.py --skills-dir path/to/skills --json-dir path/to/json
```

**参数：**

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--skills-dir` | Skills MD 文件目录 | `skills` |
| `--json-dir` | JSON 定义文件目录 | `tools/mcp/mcp_definitions` |
| `--dry-run` | 仅打印差异，不实际修改 JSON | 否 |

---

## 生成的 MD 文件结构

```markdown
---
name: create_alarm
domain: alarm
description: 专用于新建/创建闹钟的工具
---

# create_alarm

## 简要描述
`create_alarm` 是一个专用于【新建/创建闹钟】的工具。

## 能力范围
1. **新建闹钟**：必须解析出具体的【时间点】。
...

## 参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| raw_datetime | string | ✅ | 用户表达的时间 | `明早8点` |
| ...    | ...  | ...  | ...  | ...  |

## 输出参数

​```json
{
  "type": "object",
  "properties": { ... },
  "required": [ ... ]
}
​```
```

---

## 回写规则

编辑 MD 文件后执行 `sync_skills_to_json.py`，以下规则决定哪些内容会被同步：

| MD 区域 | 回写目标 | 说明 |
|---------|---------|------|
| YAML frontmatter (`---...---`) | ❌ 不回写 | 仅作元信息展示 |
| `# 标题` | ❌ 不回写 | 仅作标题展示 |
| 正文（frontmatter 与 `## 参数` 之间） | ✅ → `definition.description` | 支持完整 Markdown 格式 |
| `## 参数`（表格） | ❌ 不回写 | 仅作可读性展示，由 JSON 生成 |
| `## 输出参数`（JSON 代码块） | ✅ → `definition.parameters` | 必须是合法 JSON |

> **重要**：如需修改参数定义，请编辑 `## 输出参数` 下的 JSON 代码块，而不是 `## 参数` 表格。表格在下次 `generate` 时会根据 JSON 重新生成。

---

## 典型工作流

### 场景 1：新增 JSON 定义后生成 MD

```bash
# 1. 添加 JSON 文件到 tools/mcp/mcp_definitions/{domain}/
# 2. 生成对应的 MD
python3 scripts/generate_skills_from_json.py
```

### 场景 2：在 MD 中修改描述后同步回 JSON

```bash
# 1. 编辑 skills/{domain}/{tool_name}.md 中的正文描述
# 2. 预览差异
python3 scripts/sync_skills_to_json.py --dry-run
# 3. 确认无误后执行回写
python3 scripts/sync_skills_to_json.py
```

### 场景 3：JSON 有更新，需要刷新所有 MD

```bash
# 覆盖重新生成
python3 scripts/generate_skills_from_json.py --overwrite
# 验证一致性（应显示 0 更新）
python3 scripts/sync_skills_to_json.py --dry-run
```
