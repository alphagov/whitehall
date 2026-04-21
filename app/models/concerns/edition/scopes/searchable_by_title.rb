module Edition::Scopes::SearchableByTitle
  extend ActiveSupport::Concern

  included do
    scope :with_title_containing, lambda { |keywords|
      escaped_like_expression = keywords.gsub(/([%_])/, "%" => '\\%', "_" => '\\_')
      like_clause = "%#{escaped_like_expression}%"

      if keywords.match?(/\A[a-z0-9]+(-[a-z0-9]+)+\z/)
        where(slug: keywords)
      else
        in_default_locale
          .includes(:document)
          .where("edition_translations.title LIKE ?", like_clause)
      end
    }
  end
end
