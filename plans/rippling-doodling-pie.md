# 基于 Taxonomy 的 Markdown Lint 能力封装计划

## 目标
将现有的 remark 工具封装为 Claude Code 技能，符合 `docs/taxonomy-rfc.md` 的三层模型：
- **Layer 3 (Execution)**: `skill:lint-markdown` + `command:lint-markdown`
- **Layer 2 (Governance)**: 路由配置和规则加载
- **Layer 1 (UI)**: slash command `/lint-markdown`

## 架构设计

### 1. 技能层 (skill:lint-markdown)
**位置**: `skills/lint-markdown/SKILL.md`

**功能**:
- 封装 remark 工具的调用逻辑
- 实现三级文件分类策略（STRICT/MODERATE/LIGHT）
- 解析 remark 输出为结构化报告
- 提供自动修复能力

**集成**:
- 依赖 `skill:workflow-discipline`
- 依赖 `skill:environment-validation`
- 使用 `npm run lint:md:*` scripts

### 2. 命令层 (command:lint-markdown)
**位置**: `commands/lint-markdown.md`

**功能**:
- 提供用户友好的 slash command 入口
- 参数解析和验证
- 调用 `router:workflow-helper` → `agent:lint-markdown`

**参数设计**:
```bash
/lint-markdown [path] [--strict] [--fix] [--report] [--quick]
```

**路由**: 通过 `router:workflow-helper` 调用 `agent:lint-markdown`

### 3. 代理层 (agent:lint-markdown)
**位置**: `agents/lint-markdown/AGENT.md`

**功能**:
- 执行 DEPTH 工作流（Decomposition, Explicit Reasoning, Parameters, Tests, Heuristics）
- 协调技能调用和工具执行
- 生成结构化的 linting 报告

**技能栈**:
- `skill:lint-markdown`（主要）
- `skill:workflow-discipline`（必需）
- `skill:environment-validation`（必需）

## 实现细节

### 1. 技能实现 (SKILL.md)

```yaml
---
name: lint-markdown
description: Execute markdown linting with taxonomy-based rules.
  Use when validating markdown compliance with LLM-facing writing standards.
  Performs STRICT/MODERATE/LIGHT checks based on file path.
layer: execution
mode: validation-and-reporting
capability-level: 1
allowed-tools:
  - Bash(remark)
  - Bash(npm)
  - Read
  - Glob
  - Grep
related-skills:
  - skill:workflow-discipline
  - skill:environment-validation
---
```

### 2. 命令实现 (lint-markdown.md)

```yaml
---
name: lint-markdown
description: Validate and fix markdown formatting with taxonomy-based rules
argument-hint: '[path] [--strict] [--fix] [--report]'
style: minimal-chat
is_background: false
---
```

### 3. 代理实现 (AGENT.md)

遵循 DEPTH 模式：
- **Decomposition**: 分析路径，确定文件类别
- **Explicit Reasoning**: 应用对应的 linting 规则
- **Parameters**: 处理参数选项
- **Tests**: 验证工具链可用性
- **Heuristics**: 生成修复建议

## 工作流程

1. **Layer 1**: 用户执行 `/lint-markdown [path] [--fix]`
2. **Layer 2**: 路由到 `router:workflow-helper`
3. **Layer 3**: `agent:lint-markdown` 加载技能栈
4. **技能执行**: `skill:lint-markdown` 调用 remark 工具
5. **结果聚合**: 生成结构化报告和建议
6. **输出**: 返回分类结果和修复建议

## 工具链集成

**使用现有 remark 基础设施**:
- `.remarkrc.mjs` - 分级规则配置
- `.remarkignore` - 智能过滤
- `package.json` scripts - 自动化操作
- `tools/remark-preset-claude/index.mjs` - 自定义规则

## 自举约束 (Bootstrapping)

### 关键要求
我们正在创建的 `lint-markdown` 组件本身就是 LLM-facing 文件，必须：
- **SKILL.md** 遵循 `rules/99-llm-prompt-writing-rules.md` 的所有约束
- **AGENT.md** 必须通过 STRICT 级别的 remark 检测
- **command/lint-markdown.md** 符合命令规范和格式要求

### 自我验证机制
1. **创建后立即验证**: 每个组件创建完成后，运行 `/lint-markdown` 自我检查
2. **合规性报告**: 确保生成的文件通过 remark 检测
3. **修复循环**: 如有违规，自动修复并重新验证

### 关键约束点
- **禁止粗体**: 代码解释中不得使用 `**bold**`
- **禁止模态动词**: 避免 "may", "might", "could"
- **强制 imperative**: 所有段落以动词开头
- **标题顺序**: 必须遵循 canonical ordering
- **行长度限制**: ≤ 100 字符

## 优势

1. **符合架构**: 完全遵循 taxonomy-rfc.md 三层模型
2. **可复用**: 技能可被其他代理调用
3. **可扩展**: 新增文件类型只需更新分类规则
4. **自动化**: 支持自动修复和报告生成
5. **标准化**: 使用 Claude Code 标准的工作流程
6. **自举能力**: **工具本身必须通过自己的验证**，实现真正的约束力

## 风险和缓解

1. **依赖问题**: remark 工具的依赖包问题
   - 缓解: 添加环境验证和自动安装
2. **性能问题**: 大型仓库的扫描性能
   - 缓解: 提供 `--quick` 模式跳过详细分析
3. **准确性**: 规则匹配可能误报
   - 缓解: 基于 taxonomy 的精确分类策略

## 下一步行动

1. 创建 `skills/lint-markdown/SKILL.md`
   - 立即运行 `npm run lint:md` 自我验证
   - 如有违规，修复并重新验证

2. 创建 `commands/lint-markdown.md`
   - 验证通过 remark 检测
   - 确保符合命令格式规范

3. 创建 `agents/lint-markdown/AGENT.md`
   - 执行 DEPTH 模式合规性检查
   - 验证所有必需标题和格式要求

4. 配置 governance 路由
   - 更新 CLAUDE.md 路由映射
   - 添加到 router:workflow-helper

5. 测试完整工作流程
   - 执行 `/lint-markdown self-test`
   - 验证自举机制生效