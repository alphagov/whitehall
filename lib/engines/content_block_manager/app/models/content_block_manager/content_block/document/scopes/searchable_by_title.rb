module ContentBlockManager
  module ContentBlock::Document::Scopes::SearchableByTitle
    extend ActiveSupport::Concern

    included do
      scope :with_title,
            lambda { |*keywords|
              pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
              where("title REGEXP :pattern", pattern:)
            }
    end
  end
end
