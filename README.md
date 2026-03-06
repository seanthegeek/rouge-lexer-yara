# rouge-lexer-yara

A Rouge lexer plugin for [YARA](https://virustotal.github.io/yara/), the pattern-matching language used for malware identification and classification. Rouge is the default syntax highlighter for Jekyll (and therefore GitHub Pages). This gem adds YARA support to Rouge.

## Installation

Install the gem directly:

```sh
gem install rouge-lexer-yara
```

Or add it to your `Gemfile`:

```ruby
gem 'rouge-lexer-yara'
```

Then run:

```sh
bundle install
```

## Usage

Once installed, Rouge will automatically discover the lexer. You can use `yara` or `yar` as the language tag in fenced code blocks:

````markdown
```yara
rule ExampleRule {
    strings:
        $text = "malware" ascii wide nocase
    condition:
        any of them
}
```
````

## Jekyll / GitHub Pages

Add the gem to your site's `Gemfile` inside the `:jekyll_plugins` group:

```ruby
group :jekyll_plugins do
  gem "rouge-lexer-yara"
end
```

Run `bundle install`, then use ` ```yara ` fences in your posts and pages. Jekyll will pick up the lexer automatically via Rouge's plugin discovery.

## Development

Install dependencies:

```sh
bundle install
```

Run the test suite:

```sh
bundle exec rake
```

Start the visual preview server (available at http://localhost:9292):

```sh
bundle exec rake server
```

Run the terminal preview script:

```sh
ruby preview.rb
```

Enable debug mode to print each token and its value:

```sh
DEBUG=1 ruby preview.rb
```

### Iterative testing workflow

1. Run `bundle exec rake` to check for test failures and error tokens.
2. Start the server with `bundle exec rake server`.
3. In another terminal, check for error tokens in the rendered output:

   ```sh
   curl -s http://localhost:9292 | grep 'class="err"'
   ```

4. Fix any error tokens in `lib/rouge/lexers/yara.rb`.
5. Repeat until no error tokens remain.

## License

MIT
