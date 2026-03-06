# frozen_string_literal: true

require 'rouge'
require_relative 'lib/rouge/lexer/yara'

lexer = Rouge::Lexer.find('yara')

sample_path = File.join(__dir__, 'spec', 'visual', 'samples', 'yara')
sample = File.read(sample_path)

if ENV['DEBUG']
  lexer.lex(sample) { |tok, val| puts "#{tok.qualname.ljust(30)} #{val.inspect}" }
else
  formatter = Rouge::Formatters::Terminal256.new(Rouge::Themes::Github.new)
  puts formatter.format(lexer.lex(sample))
end
