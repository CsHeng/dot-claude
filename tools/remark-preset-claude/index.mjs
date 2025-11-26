import path from 'node:path'
import {lintRule} from 'unified-lint-rule'
import {visit} from 'unist-util-visit'
import {visitParents} from 'unist-util-visit-parents'
import {minimatch} from 'minimatch'
import emojiRegex from 'emoji-regex'
import {toString} from 'mdast-util-to-string'

// Three-tier file classification system based on taxonomy-rfc.md
const STRICT_GLOBS = [
  'commands/**/*.md',
  'skills/**/SKILL.md',
  'agents/**/AGENT.md',
  'rules/**/*.md',
  'AGENTS.md',
  'CLAUDE.md',
]

const MODERATE_GLOBS = [
  'governance/**/*.md',
  'config-sync/**/*.md',
  'agent-ops/**/*.md',
]

const LIGHT_GLOBS = [
  '**/*.md',
]

const EXPECTED_HEADINGS = [
  'scope',
  'absolute-prohibitions',
  'communication-protocol',
  'structural-rules',
  'language-rules',
  'formatting-rules',
  'naming-rules',
  'validation-rules',
  'narrative-detection',
  'depth-compatibility',
]

const MODERATE_HEADINGS = [
  'purpose',
  'scope',
  'workflow',
  'configuration',
]

const DIRECTIVE_START = new Set([
  'required', 'prohibited', 'optional', 'allowed', 'ensure', 'use', 'keep',
  'set', 'write', 'avoid', 'preserve', 'maintain', 'follow', 'apply',
  'define', 'treat', 'skip', 'execute', 'disable', 'enable', 'list',
  'include', 'exclude', 'respect', 'align', 'load', 'route', 'escalate',
  'run', 'add', 'remove', 'update', 'create', 'delete', 'validate',
  'check', 'test', 'build', 'deploy', 'configure', 'implement',
])

const MODAL_RE = /\b(may|might|could)\b/i
const SUBJECTIVE_RE = /\b(usually|typically|generally|often|maybe|perhaps|probably)\b/i
const NARRATIVE_START_RE = /^(this|the|that|these|those|our|we|you|they|it|a|an)\s/i
const emojiRe = emojiRegex()

const getFileCategory = (file) => {
  if (!file.path) return 'none'
  const rel = path.relative(process.cwd(), file.path)

  // STRICT: LLM-facing files requiring full compliance
  if (STRICT_GLOBS.some((g) => minimatch(rel, g, {nocase: true}))) {
    return 'strict'
  }

  // MODERATE: Governance and orchestration files
  if (MODERATE_GLOBS.some((g) => minimatch(rel, g, {nocase: true}))) {
    return 'moderate'
  }

  // LIGHT: Other .md files (excluding human-facing docs in .remarkignore)
  if (LIGHT_GLOBS.some((g) => minimatch(rel, g, {nocase: true}))) {
    return 'light'
  }

  return 'none'
}

const isStrictFile = (file) => getFileCategory(file) === 'strict'
const isModerateFile = (file) => getFileCategory(file) === 'moderate'
const isLightFile = (file) => getFileCategory(file) === 'light'

const hasCodeAncestor = (ancestors) =>
  Array.isArray(ancestors) && ancestors.some((a) => a.type === 'code' || a.type === 'inlineCode')

// STRICT: Full LLM-facing compliance
const headingOrderRule = lintRule('remark-claude:heading-order', (tree, file) => {
  if (!isStrictFile(file)) return

  const seen = []
  visit(tree, 'heading', (node) => {
    const text = toString(node).trim().toLowerCase()
    const idx = EXPECTED_HEADINGS.indexOf(text)
    if (idx !== -1) {
      seen.push({idx, node})
    }
  })

  // Order check
  let last = -1
  for (const {idx, node} of seen) {
    if (idx < last) {
      file.message('Headings must follow the canonical order defined for LLM-facing files', node)
      break
    }
    last = idx
  }

  // Missing required headings
  const missing = EXPECTED_HEADINGS.filter(
    (heading) => !seen.some((s) => s.idx === EXPECTED_HEADINGS.indexOf(heading)),
  )
  if (missing.length) {
    file.message(`Missing required headings: ${missing.join(', ')}`)
  }
})

const noStrongRule = lintRule('remark-claude:no-strong', (tree, file) => {
  if (!isStrictFile(file)) return
  visit(tree, 'strong', (node) => {
    file.message('Bold/strong emphasis is prohibited in LLM-facing files', node)
  })
})

const noEmojiRule = lintRule('remark-claude:no-emoji', (tree, file) => {
  if (!isStrictFile(file)) return
  visitParents(tree, 'text', (node, ancestors) => {
    if (hasCodeAncestor(ancestors)) return
    const match = node.value.match(emojiRe)
    if (match) {
      file.message('Emojis are prohibited in LLM-facing files', node)
    }
  })
})

const noModalRule = lintRule('remark-claude:no-modal-verbs', (tree, file) => {
  if (!isStrictFile(file)) return
  visitParents(tree, 'text', (node, ancestors) => {
    if (hasCodeAncestor(ancestors)) return
    if (MODAL_RE.test(node.value)) {
      file.message('Modal verbs (may/might/could) are prohibited in body content', node)
    }
  })
})

const narrativeRule = lintRule('remark-claude:no-narrative', (tree, file) => {
  if (!isStrictFile(file)) return
  visit(tree, 'paragraph', (node) => {
    const text = toString(node).trim()
    if (!text) return
    const firstWord = text.replace(/^[-*+]\s+/, '').split(/\s+/)[0].replace(/[^A-Za-z-]/g, '').toLowerCase()
    const directive = DIRECTIVE_START.has(firstWord)
    const hasSubjective = SUBJECTIVE_RE.test(text)
    const hasModal = MODAL_RE.test(text)
    const hasNarrativeStart = NARRATIVE_START_RE.test(text)

    if (!directive || hasSubjective || hasModal || hasNarrativeStart) {
      file.message('Paragraph must be imperative/directive; remove narrative or subjective language', node)
    }
  })
})

const lineLengthRule = lintRule('remark-claude:line-length', (tree, file) => {
  if (!isStrictFile(file)) return
  const contents = String(file)
  const lines = contents.split(/\r?\n/)
  let inFence = false

  lines.forEach((line, i) => {
    const trimmed = line.trim()
    if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
      inFence = !inFence
      return
    }
    if (inFence) return
    if (trimmed.startsWith('|')) return // skip simple tables

    if (line.length > 100) {
      file.message('Lines must be ≤ 100 characters in LLM-facing files', {
        line: i + 1,
        column: 101,
      })
    }
  })
})

// MODERATE: Governance files with relaxed rules
const moderateHeadingRule = lintRule('remark-claude:moderate-headings', (tree, file) => {
  if (!isModerateFile(file)) return

  const seen = []
  visit(tree, 'heading', (node) => {
    const text = toString(node).trim().toLowerCase()
    const idx = MODERATE_HEADINGS.indexOf(text)
    if (idx !== -1) {
      seen.push({idx, node})
    }
  })

  // Only warn for missing common governance headings
  const missing = MODERATE_HEADINGS.filter(
    (heading) => !seen.some((s) => s.idx === MODERATE_HEADINGS.indexOf(heading)),
  )
  if (missing.length && missing.length <= 2) {
    file.message(`Consider adding these governance headings: ${missing.join(', ')}`)
  }
})

const moderateMarkdownRule = lintRule('remark-claude:moderate-markdown', (tree, file) => {
  if (!isModerateFile(file)) return

  visit(tree, 'paragraph', (node) => {
    const text = toString(node).trim()
    if (!text) return

    // Only flag excessive issues in moderate mode
    const hasExcessiveSubjective = text.match(new RegExp(SUBJECTIVE_RE, 'gi'))?.length > 2
    const hasExcessiveModal = text.match(new RegExp(MODAL_RE, 'gi'))?.length > 1
    const hasExcessiveBold = text.includes('**') || text.includes('__')

    if (hasExcessiveSubjective || hasExcessiveModal || hasExcessiveBold) {
      file.message('Governance files should use direct, professional language', node)
    }
  })
})

// LIGHT: Basic markdown compliance for all other files
const lightMarkdownRule = lintRule('remark-claude:light-markdown', (tree, file) => {
  if (!isLightFile(file)) return

  visit(tree, 'paragraph', (node) => {
    const text = toString(node).trim()
    if (!text) return

    // Only flag extreme cases in light mode
    const hasExtremeSubjective = text.match(new RegExp(SUBJECTIVE_RE, 'gi'))?.length > 4
    const hasExtremeModal = text.match(new RegExp(MODAL_RE, 'gi'))?.length > 2

    if (hasExtremeSubjective || hasExtremeModal) {
      file.message('Consider using more direct language', node)
    }
  })
})

export default {
  plugins: [
    // Strict LLM-facing rules
    headingOrderRule,
    noStrongRule,
    noEmojiRule,
    noModalRule,
    narrativeRule,
    lineLengthRule,

    // Moderate governance rules
    moderateHeadingRule,
    moderateMarkdownRule,

    // Light markdown rules
    lightMarkdownRule,
  ],
}
