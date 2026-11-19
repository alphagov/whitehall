module Edition::Scopes::SearchableByTitle
  extend ActiveSupport::Concern

  included do
    scope :with_title_containing, lambda { |keywords, locale: I18n.default_locale|
      slug_keyword_candidate = keywords.to_s.sub(%r{[?#].*\z}, "").split("/").last.to_s.downcase

      if slug_keyword_candidate.match?(/\A[a-z0-9]+(-[a-z0-9]+)+\z/) && exists?(slug: slug_keyword_candidate)
        where(slug: slug_keyword_candidate)
      else
        matching_titles = Edition::Translation
                            .where(locale:)
                            .where("title LIKE ?", "%#{sanitize_sql_like(keywords)}%")
                            .select(:edition_id)

        where(id: matching_titles)
      end
    }
  end
end
