---
name: docs
description: Find a section in .md/.txt/.html docs with docindex and answer from only those lines. /wanjang:docs <query> [dir]
---
Answer a question from documents without reading them whole.

1. Run `docindex search "<query>" <dir>` with the Bash tool (`<dir>` defaults to the current directory; `-n 5` for fewer hits). If `docindex` is not on PATH, run `${CLAUDE_PLUGIN_ROOT}/bin/docindex`; do not read the documents whole instead.
2. Each hit is `path:start-end  heading trail` plus a snippet. If the snippets do not answer it, run `docindex outline <file>` to pick a range, or search again with other words.
3. Read only the line ranges needed (Read with offset/limit), nothing more.
4. Answer with `path:line` citations. Say plainly when the documents do not contain the answer.
