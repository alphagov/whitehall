module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByKeyword
    extend ActiveSupport::Concern

    included do
      scope :with_keyword,
            lambda { |keywords|
              split_keywords = keywords.split
              pattern = split_keywords.map { |k|
                escaped_word = Regexp.escape(k)
                "(?=.*#{escaped_word})"
              }.join
              joins(:latest_edition)
                .where("content_block_documents.title REGEXP :pattern OR content_block_editions.details REGEXP :pattern", pattern:)
            }
    end
  end
end
