module Whitehall
  class ExtraQuoteRemover
    QUOTE = '"\u201C\u201D\u201E\u201F\u2033\u2036'.freeze
    LINE_BREAK = '\r\n?|\n'.freeze

    def remove(source)
      return nil if source.nil?
      source.gsub(/^>[ \t]*[#{QUOTE}]*([^ \t\n].+?)[#{QUOTE}]*[ \t]*(#{LINE_BREAK}?)$/, '> \1\2')
    end
  end
end
