module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByTitle
    extend ActiveSupport::Concern

    included do
      scope :with_title,
            lambda { |keywords|
              split_keywords = keywords.split
              pattern = ""
              split_keywords.map do |k|
                escaped_word = Regexp.escape(k)
                pattern += "(?=.*#{escaped_word})"
              end
              where("title REGEXP :pattern", pattern:)
            }
    end
  end
end
