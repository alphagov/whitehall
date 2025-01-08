module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByKeyword
    extend ActiveSupport::Concern

    SQL = <<-SQL.freeze
        content_block_editions.title REGEXP :pattern OR#{' '}
        content_block_editions.details REGEXP :pattern OR#{' '}
        content_block_editions.instructions_to_publishers REGEXP :pattern
    SQL

    included do
      scope :with_keyword,
            lambda { |keywords|
              split_keywords = keywords.split
              pattern = split_keywords.map { |k|
                escaped_word = Regexp.escape(k)
                "(?=.*#{escaped_word})"
              }.join
              joins(:latest_edition)
                .where(SQL, pattern:)
            }
    end
  end
end
