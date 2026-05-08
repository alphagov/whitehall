module Edition::Scopes::SearchableByTitle
  extend ActiveSupport::Concern

  included do
    scope :with_title_containing, lambda { |keywords|
      like_clause = "%#{sanitize_sql_like(keywords)}%"
      slug_keyword_candidate = keywords.to_s.sub(%r{[?#].*\z}, "").split("/").last

      if slug_keyword_candidate.match?(/\A[a-z0-9]+(-[a-z0-9]+)+\z/)
        where(slug: slug_keyword_candidate)
      else
        in_default_locale
          .includes(:document)
          .where("edition_translations.title LIKE ?", like_clause)
      end
    }
  end
end
