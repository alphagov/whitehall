module Edition::Scopes::SearchableByTitle
  extend ActiveSupport::Concern

  included do
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
