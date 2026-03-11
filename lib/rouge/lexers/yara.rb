# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class YARA < RegexLexer
      title 'YARA'
      desc 'YARA malware pattern-matching rule language'
      tag 'yara'
      aliases 'yar'
      filenames '*.yar', '*.yara'
      mimetypes 'text/x-yara'

      def self.detect?(text)
        return true if text =~ /\A\s*(?:rule|import|include)\b/
      end

      # Rule-level and top-level declaration keywords (from writingrules.html)
      def self.keywords_declaration
        @keywords_declaration ||= Set.new %w(
          rule import include
        )
      end

      # String modifiers only (from writingrules.html "String Modifiers" section)
      def self.keywords_pseudo
        @keywords_pseudo ||= Set.new %w(
          ascii base64 base64wide fullword nocase private wide xor
        )
      end

      # Boolean constants (from writingrules.html)
      def self.keywords_constant
        @keywords_constant ||= Set.new %w(
          true false
        )
      end

      # Rule modifiers and condition keywords (from writingrules.html)
      def self.keywords
        @keywords ||= Set.new %w(
          all and any at condition contains defined endswith entrypoint
          filesize for global icontains iendswith iequals in istartswith
          matches meta none not of or startswith strings them
        )
      end

      # Integer read functions (from writingrules.html "Accessing data at a given position")
      def self.builtins
        @builtins ||= Set.new %w(
          int8 int16 int32 uint8 uint16 uint32
          int8be int16be int32be uint8be uint16be uint32be
        )
      end

      state :root do
        rule %r/\s+/, Text::Whitespace

        # single-line comment
        rule %r(//.*$), Comment::Single

        # multiline comment
        rule %r(/\*), Comment::Multiline, :multiline_comment

        # section labels: meta: strings: condition:
        rule %r/(meta|strings|condition)(\s*)(:)/ do
          groups Name::Label, Text::Whitespace, Punctuation
        end

        # hex string assignment: identifier = { ... }
        # Must come before the '=' single-char operator rule
        rule %r/(=)(\s*)(\{)/m do
          groups Operator, Text::Whitespace, Str::Other
          push :hex_string
        end

        # double-quoted strings
        rule %r/"/, Str::Double, :string

        # regex literals: /pattern/flags
        # Only treat '/' as a regex start when preceded by context that
        # implies a value position (after '=', 'matches', or at a
        # definition context). We use a heuristic: if a word char or
        # closing bracket follows '/' it is more likely division;
        # otherwise enter regex. For YARA, regex literals appear only in
        # string definitions ($x = /.../) or after 'matches', so we
        # accept '/' followed by a non-space non-'/' character.
        rule %r((?<![0-9a-zA-Z_\)\]])/(?![/*\s])) do
          token Str::Regex
          push :regex
        end

        # string variables: $ident or bare $
        rule %r/\$\w+/, Name::Variable
        rule %r/\$/, Name::Variable

        # count (#ident), offset (@ident), length (!ident) references
        rule %r/[#@!]\w+/, Name::Variable

        # hexadecimal numbers (must come before decimal)
        rule %r/0x[0-9a-fA-F]+/, Num::Hex

        # floating-point numbers must come before integers so 7.2 isn't split
        rule %r/\d+\.\d+/, Num::Float

        # decimal integers with optional size suffix (KB, MB)
        rule %r/\d+(?:KB|MB)?/, Num::Integer

        # range operator (..)
        rule %r/\.\./, Operator

        # multi-character operators
        rule %r/==|!=|<=|>=|<<|>>/, Operator

        # single-character operators (includes \ for integer division per YARA docs)
        rule %r([+\-*\\/%&|^~<>=]), Operator

        # punctuation
        rule %r/[{}()\[\]:.,]/, Punctuation

        # identifiers and keywords
        rule %r/\w+/ do |m|
          if self.class.keywords_declaration.include?(m[0])
            token Keyword::Declaration
          elsif self.class.keywords_pseudo.include?(m[0])
            token Keyword::Pseudo
          elsif self.class.keywords_constant.include?(m[0])
            token Keyword::Constant
          elsif self.class.builtins.include?(m[0])
            token Name::Builtin
          elsif self.class.keywords.include?(m[0])
            token Keyword
          else
            token Name
          end
        end
      end

      state :multiline_comment do
        rule %r([*]/), Comment::Multiline, :pop!
        rule %r([^*]+), Comment::Multiline
        rule %r([*]), Comment::Multiline
      end

      state :string do
        rule %r/\\./, Str::Escape
        rule %r/"/, Str::Double, :pop!
        rule %r/[^\\"]+/, Str::Double
      end

      state :hex_string do
        rule %r/\s+/, Text::Whitespace
        rule %r/\}/, Str::Other, :pop!

        # Comments inside hex strings
        rule %r(//.*$), Comment::Single
        rule %r(/\*), Comment::Multiline, :multiline_comment

        # Negated nibble wildcard: ~?F or ~??
        rule %r/~[0-9a-fA-F?]{2}/, Str::Other

        # Two hex nibbles or wildcards (e.g. 4D, ??, A?, ?B)
        rule %r/[0-9a-fA-F?]{2}/, Str::Other

        # Jump ranges: [4], [4-8], [10-], [-], etc.
        rule %r/\[\s*\d*\s*(?:-\s*\d*)?\s*\]/, Str::Other

        # Alternatives separator and grouping
        rule %r/[|()]/, Punctuation
      end

      state :regex do
        rule %r/\\./, Str::Regex
        rule %r(/[is]*), Str::Regex, :pop!
        rule %r([^\\/]+), Str::Regex
      end
    end
  end
end
