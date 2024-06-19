module Edition::Scopes::Orderable
  extend ActiveSupport::Concern

  included do
    scope :alphabetical, lambda { |locale = I18n.locale|
      with_translations(locale).order("edition_translations.title ASC")
    }

    scope :in_chronological_order, lambda {
      order(arel_table[:public_timestamp].asc, arel_table[:document_id].asc)
    }

    scope :in_reverse_chronological_order, lambda {
      ids = pluck(:id)
      Edition
        .unscoped
        .where(id: ids)
        .order(
          arel_table[:public_timestamp].desc,
          arel_table[:document_id].desc,
          arel_table[:id].desc,
        )
    }
  end
end
