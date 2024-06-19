module Edition::Scopes::FilterableByDate
  extend ActiveSupport::Concern

  included do
    scope :published_before, lambda { |date|
      where(arel_table[:public_timestamp].lteq(date))
    }

    scope :published_after, lambda { |date|
      where(arel_table[:public_timestamp].gteq(date))
    }

    scope :from_date, ->(date) { where("editions.updated_at >= ?", date) }
    scope :to_date, ->(date) { where("editions.updated_at <= ?", date) }
  end
end
