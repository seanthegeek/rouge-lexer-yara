# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Commands

```sh
bundle install          # Install dependencies
bundle exec rake        # Run the test suite (default task)
bundle exec rake server # Start visual preview server at http://localhost:9292
ruby preview.rb         # Terminal preview with syntax highlighting
DEBUG=1 ruby preview.rb # Print each token and its type
```

Check for error tokens in the running preview server:

```sh
curl -s http://localhost:9292 | grep 'class="err"'
```

## Architecture

This is a [Rouge](https://github.com/rouge-ruby/rouge) lexer plugin gem for YARA syntax highlighting. Rouge is the default syntax highlighter for Jekyll/GitHub Pages.

**Key files:**

- [lib/rouge/lexers/yara.rb](lib/rouge/lexers/yara.rb) — The lexer implementation (the only production code file)
- [spec/rouge_lexer_yara_spec.rb](spec/rouge_lexer_yara_spec.rb) — Minitest test suite
- [spec/demos/yara](spec/demos/yara) — Short demo snippet shown in Rouge's lexer catalog
- [spec/visual/samples/yara](spec/visual/samples/yara) — Comprehensive YARA sample covering all syntax elements; used by both tests and the preview server

**Lexer structure (`Rouge::Lexers::YARA < RegexLexer`):**

The lexer uses Rouge's state-machine approach with these states:

- `:root` — main state; handles whitespace, comments, section labels (`meta:`, `strings:`, `condition:`), string/hex/regex literals, variables (`$`, `#`, `@`, `!`), numbers, operators, punctuation, and keyword classification
- `:multiline_comment` — inside `/* ... */`
- `:string` — inside `"..."` double-quoted strings with escape handling
- `:hex_string` — inside `{ ... }` hex byte patterns (wildcards `??`, jumps `[n-m]`, alternatives `|`, negation `~`)
- `:regex` — inside `/ ... /` regex literals with optional `i`/`s` flags

**Token taxonomy used:**

- `Keyword::Declaration` — `rule`, `import`, `include`
- `Keyword::Pseudo` — string modifiers: `ascii`, `wide`, `nocase`, `fullword`, `xor`, `base64`, `base64wide`, `private`
- `Keyword::Constant` — `true`, `false`
- `Keyword` — condition keywords: `all`, `and`, `any`, `at`, `condition`, `for`, `of`, etc.
- `Name::Builtin` — integer read functions: `uint8`, `int32be`, etc.
- `Name::Variable` — `$ident`, `#ident`, `@ident`, `!ident`
- `Name::Label` — section names (`meta`, `strings`, `condition`) before `:`
- `Str::Double` / `Str::Escape` / `Str::Other` / `Str::Regex` — string types
- `Comment::Single` / `Comment::Multiline`

### Documentation

**MANDATORY: Before writing or modifying the lexer, you MUST fetch and read every
URL in this list.** This is not background reading — it is a required prerequisite
step. Fetch each page, extract the keywords or function names, and verify them
against the lexer before declaring any work complete.

- Writing YARA rules <https://yara.readthedocs.io/en/stable/writingrules.html>
- Comments <https://yara.readthedocs.io/en/stable/writingrules.html#comments>
- Strings <https://yara.readthedocs.io/en/stable/writingrules.html#strings>
- Hexadecimal strings <https://yara.readthedocs.io/en/stable/writingrules.html#hexadecimal-strings>
- Text strings <https://yara.readthedocs.io/en/stable/writingrules.html#text-strings>
- Case-insensitive strings <https://yara.readthedocs.io/en/stable/writingrules.html#case-insensitive-strings>
- Wide-character strings <https://yara.readthedocs.io/en/stable/writingrules.html#wide-character-strings>
- XOR strings <https://yara.readthedocs.io/en/stable/writingrules.html#xor-strings>
- Base64 strings <https://yara.readthedocs.io/en/stable/writingrules.html#base64-strings>
- Searching for full words <https://yara.readthedocs.io/en/stable/writingrules.html#searching-for-full-words>
- Regular expressions <https://yara.readthedocs.io/en/stable/writingrules.html#regular-expressions>
- Private strings <https://yara.readthedocs.io/en/stable/writingrules.html#private-strings>
- Unreferenced strings <https://yara.readthedocs.io/en/stable/writingrules.html#unreferenced-strings>
- String Modifier Summary <https://yara.readthedocs.io/en/stable/writingrules.html#string-modifier-summary>
- Conditions <https://yara.readthedocs.io/en/stable/writingrules.html#conditions>
- Counting strings <https://yara.readthedocs.io/en/stable/writingrules.html#counting-strings>
- String offsets or virtual addresses <https://yara.readthedocs.io/en/stable/writingrules.html#string-offsets-or-virtual-addresses>
- Match length <https://yara.readthedocs.io/en/stable/writingrules.html#match-length>
- File size <https://yara.readthedocs.io/en/stable/writingrules.html#file-size>
- Executable entry point <https://yara.readthedocs.io/en/stable/writingrules.html#executable-entry-point>
- Accessing data at a given position <https://yara.readthedocs.io/en/stable/writingrules.html#accessing-data-at-a-given-position>
- Sets of strings <https://yara.readthedocs.io/en/stable/writingrules.html#sets-of-strings>
- Applying the same condition to many strings <https://yara.readthedocs.io/en/stable/writingrules.html#applying-the-same-condition-to-many-strings>
- Using anonymous strings with of and for..of <https://yara.readthedocs.io/en/stable/writingrules.html#using-anonymous-strings-with-of-and-for-of>
- Iterating over string occurrences <https://yara.readthedocs.io/en/stable/writingrules.html#iterating-over-string-occurrences>
- Iterators <https://yara.readthedocs.io/en/stable/writingrules.html#iterators>
- Referencing other rules <https://yara.readthedocs.io/en/stable/writingrules.html#referencing-other-rules>
- More about rules <https://yara.readthedocs.io/en/stable/writingrules.html#more-about-rules>
- Global rules <https://yara.readthedocs.io/en/stable/writingrules.html#global-rules>
- Private rules <https://yara.readthedocs.io/en/stable/writingrules.html#private-rules>
- Rule tags <https://yara.readthedocs.io/en/stable/writingrules.html#rule-tags>
- Metadata <https://yara.readthedocs.io/en/stable/writingrules.html#metadata>
- Using modules <https://yara.readthedocs.io/en/stable/writingrules.html#using-modules>
- Undefined values <https://yara.readthedocs.io/en/stable/writingrules.html#undefined-values>
- External variables <https://yara.readthedocs.io/en/stable/writingrules.html#external-variables>
- Including files <https://yara.readthedocs.io/en/stable/writingrules.html#including-files>
- Modules <https://yara.readthedocs.io/en/stable/modules.html>
- PE <https://yara.readthedocs.io/en/stable/modules/pe.html>
- ELF <https://yara.readthedocs.io/en/stable/modules/elf.html>
- Cuckoo <https://yara.readthedocs.io/en/stable/modules/cuckoo.html>
- Magic <https://yara.readthedocs.io/en/stable/modules/magic.html>
- Hash <https://yara.readthedocs.io/en/stable/modules/hash.html>
- Math <https://yara.readthedocs.io/en/stable/modules/math.html>
- Dotnet <https://yara.readthedocs.io/en/stable/modules/dotnet.html>
- Time <https://yara.readthedocs.io/en/stable/modules/time.html>
- Console <https://yara.readthedocs.io/en/stable/modules/console.html>
- String <https://yara.readthedocs.io/en/stable/modules/string.html>
- LNK <https://yara.readthedocs.io/en/stable/modules/lnk.html>

## Rouge references

- Lexer development guide: <https://github.com/rouge-ruby/rouge/blob/main/docs/LexerDevelopment.md>
- Existing lexers for reference: <https://github.com/rouge-ruby/rouge/tree/main/lib/rouge/lexers>
- JSON lexer (simple example): <https://github.com/rouge-ruby/rouge/blob/main/lib/rouge/lexers/json.rb>
- SQL lexer (keyword-heavy analog): <https://github.com/rouge-ruby/rouge/blob/main/lib/rouge/lexers/sql.rb>
- Token types: <https://github.com/rouge-ruby/rouge/blob/main/lib/rouge/token.rb>

## Verification workflow (MANDATORY — do this BEFORE adding anything)

Before writing or modifying the lexer, fetch **every URL in the documentation
list** above. Do not begin implementation until all pages have been read.

Before adding ANY individual keyword, function, or syntax element:

1. **Fetch the relevant documentation page** using the WebFetch tool or curl.
2. **Extract and confirm** the element exists in the fetched content. Do not rely
   on training data, memory, or assumptions about what "should" exist.
3. **Only add** elements that appear in the fetched content. **Only remove**
   elements confirmed absent.

### What NOT to do

- **Do NOT add keywords or syntax from training data or memory.** Every addition
  must be traced to a specific URL from the reference list in this file.
- **Do NOT use preview/beta features** unless explicitly asked. Only add GA
  (generally available) features.
- **Do NOT fabricate or modify reference URLs.** Use ONLY the exact URLs listed
  in this file. If a URL doesn't work, say so — do not guess an alternative.
- **Do NOT assume a function exists because a similar one does.**

### Self-verification

After making changes, verify correctness by **re-fetching the source documentation**
and confirming every added element appears in the fetched HTML. Do not verify by
re-reading your own changes.

### Constraints (applies to all work)

- **No hallucinated syntax.** Every keyword, function, operator, and language
  construct in the lexer must come from the official documentation listed above.
- **Follow Rouge conventions exactly.** Study existing lexers (especially JSON and
  SQL) for patterns. Don't invent novel approaches.
- **The Error token count is the ground truth.** The visual preview server is the
  authoritative test. `bundle exec rake` passing is necessary but not sufficient —
  you must also have zero `class="err"` spans.
- **Iterate until clean.** Do not declare the task complete until both
  `bundle exec rake` passes AND the Error token count is zero for both demo and
  visual sample.
- **Update the visual sample** (`spec/visual/samples/yara}`)
  whenever new tokens are added to the lexer, so every token type has coverage.

The markdownlint configuration in [.vscode/settings.json](.vscode/settings.json)
sets `MD024` to `siblings_only: true`, allowing repeated heading text under
different parent headings (e.g. `### Added` appearing under multiple version
sections in the changelog).

## Changelog

The changelog ([CHANGELOG.md](CHANGELOG.md)) follows the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). When updating the
changelog:

- Use `## [version] - YYYY-MM-DD` for release headings
- Use `### Added`, `### Changed`, `### Removed` as second-level section headings
- Use `#### Category name` as optional third-level headings within a section
- Ensure blank lines surround all headings to satisfy markdownlint

## Final checklist

Before considering the project complete, verify:

- [ ] `bundle exec rake` passes with no test failures
- [ ] `curl -s http://localhost:9292 | grep 'class="err"'` returns nothing
- [ ] Every token type defined in the lexer has at least one example in the visual sample
- [ ] Every keyword/function in the lexer is traceable to a documentation URL
- [ ] `README.md`, `AGENTS.md`, `CLAUDE.md`, and `CHANGELOG.md` are accurate
- [ ] The gemspec version is `0.1.0` and metadata URLs are correct
