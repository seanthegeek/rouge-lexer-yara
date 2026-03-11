# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-03-11

### Added

- `Keyword::Constant` token type for `true` and `false`
- `Num::Float` token type for floating-point literals (e.g. `7.2` in `math.entropy` comparisons)
- `private` string modifier to `Keyword::Pseudo` (it was previously classified as a general keyword)

### Changed

- Reordered numeric rules so `Num::Float` is matched before `Num::Integer`, preventing `7.2` from being split into three tokens
- Replaced regex literal heuristic with a negative lookbehind (`(?<![0-9a-zA-Z_\)\]])`) to more reliably distinguish `/` regex starts from arithmetic division
- Improved hex string negation rule to correctly match `~` followed by exactly two nibble/wildcard characters (e.g. `~00`, `~?0`)
- Improved hex string jump-range regex to handle all YARA forms: `[n]`, `[n-m]`, `[n-]`, `[-]`
- Moved `private` out of `Keyword` and into `Keyword::Pseudo` (string modifier, not a condition keyword)
- Replaced placeholder demo rule (`ExampleRule`) with a realistic `Emotet_Dropper` rule
- Replaced generic visual sample with a comprehensive set of realistic malware-research rules covering all token types and all supported YARA modules (`pe`, `elf`, `hash`, `math`, `dotnet`, `time`, `console`, `string`, `cuckoo`, `magic`, `lnk`)

## [0.1.0] - 2026-03-05

### Added

- Initial Rouge lexer for the YARA pattern-matching language
- Support for all YARA string types: text strings, hexadecimal strings, and regular expressions
- All string modifiers: `ascii`, `wide`, `nocase`, `fullword`, `xor`, `base64`, `base64wide`
- Hex string features: wildcards (`??`, `A?`, `?B`), jumps (`[n-m]`), alternatives (`|`), negation (`~`)
- Condition keywords: `all`, `and`, `any`, `at`, `condition`, `contains`, `defined`, `endswith`, `entrypoint`, `filesize`, `for`, `global`, `icontains`, `iendswith`, `iequals`, `in`, `istartswith`, `matches`, `meta`, `none`, `not`, `of`, `or`, `private`, `startswith`, `strings`, `them`
- Declaration keywords: `rule`, `import`, `include`
- Integer read builtins: `int8`, `int16`, `int32`, `uint8`, `uint16`, `uint32` and big-endian variants
- `Name::Variable` tokens for string (`$`), count (`#`), offset (`@`), and length (`!`) references
- `Name::Label` tokens for section labels (`meta:`, `strings:`, `condition:`)
- `Num::Hex` and `Num::Integer` with optional `KB`/`MB` size suffixes
- Single-line (`//`) and multiline (`/* */`) comment support inside both root and hex string states
- Language detection heuristic via `detect?` (triggers on `rule`, `import`, or `include` at file start)
- File extension detection for `*.yar` and `*.yara`
- MIME type registration for `text/x-yara`
- Rake task for running the test suite and a visual preview server

[0.2.0]: https://github.com/seanthegeek/rouge-lexer-yara/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/seanthegeek/rouge-lexer-yara/releases/tag/v0.1.0
