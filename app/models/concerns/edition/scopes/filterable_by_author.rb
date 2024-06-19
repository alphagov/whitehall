module Edition::Scopes::FilterableByAuthor
  extend ActiveSupport::Concern

  included do
    scope :authored_by, lambda { |user|
      if user&.id
        where(
          "EXISTS (
          SELECT * FROM edition_authors ea_authorship_check
          WHERE
            ea_authorship_check.edition_id=editions.id
            AND ea_authorship_check.user_id=?
          )",
          user.id,
        )
      end
    }
  end
end
