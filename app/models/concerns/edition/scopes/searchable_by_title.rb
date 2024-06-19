module Edition::Scopes::SearchableByTitle
  extend ActiveSupport::Concern

  included do
    scope :with_title_or_summary_containing,
          lambda { |*keywords|
            pattern = "(#{keywords.map { |k| Regexp.escape(k) }.join('|')})"
            in_default_locale.where("edition_translations.title REGEXP :pattern OR edition_translations.summary REGEXP :pattern", pattern:)
          }

    scope :with_title_containing,
          lambda { |keywords|
            escaped_like_expression = keywords.gsub(/([%_])/, "%" => '\\%', "_" => '\\_')
            like_clause = "%#{escaped_like_expression}%"

            scope = in_default_locale.includes(:document)
            scope
              .where("edition_translations.title LIKE :like_clause", like_clause:)
              .or(scope.where(document: { slug: keywords }))
          }
  end
end
