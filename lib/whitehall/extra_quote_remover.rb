module Whitehall
  class ExtraQuoteRemover
    QUOTE = '"\u201C\u201D\u201E\u201F\u2033\u2036'
    LINE_BREAK = '\r\n?|\n'

    def remove(source)
      source.lines.map do |line|
        if line[0] == '>' && line.match(/[#{QUOTE}]/)
          line.
            sub(/^>\s*[#{QUOTE}]+/, '> ').
            sub(/[#{QUOTE}]+[ \t]*(#{LINE_BREAK})/, '\1').
            sub(/[#{QUOTE}]+[ \t]*$/, '')
        else
          line
        end
      end.join
    end
  end
end
