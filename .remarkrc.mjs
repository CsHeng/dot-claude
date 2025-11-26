import frontmatter from 'remark-frontmatter'
import gfm from 'remark-gfm'
import lintRecommended from 'remark-preset-lint-recommended'
import claudePreset from './tools/remark-preset-claude/index.mjs'

export default {
  plugins: [frontmatter, gfm, lintRecommended, claudePreset],
}
