module Edition::Scopes::SearchableByTitle
  extend ActiveSupport::Concern

  included do
    scope :with_title_containing, lambda { |keywords|
      slug_keyword_candidate = keywords.to_s.sub(%r{[?#].*\z}, "").split("/").last.to_s.downcase

      if slug_keyword_candidate.match?(/\A[a-z0-9]+(-[a-z0-9]+)+\z/) && exists?(slug: slug_keyword_candidate)
        where(slug: slug_keyword_candidate)
      else
        where(
          "editions.id IN (SELECT et_titlecheck.edition_id FROM edition_translations et_titlecheck
                           WHERE et_titlecheck.locale = :locale
                           AND et_titlecheck.title LIKE :title)",
          locale: I18n.default_locale,
          title: "%#{sanitize_sql_like(keywords)}%",
        )
      end
    }
  end
end
