module Edition::Scopes::FilterableByInvalid
  extend ActiveSupport::Concern

  included do
    scope :only_invalid_editions, lambda {
      where(revalidated_at: nil)
        .where.not(state: %w[superseded deleted]) # We don't care if editions are invalid if they're superseded
    }

    scope :not_validated_since, lambda { |from_date|
      cutoff = Time.zone.parse(from_date.to_s)
      where("revalidated_at IS NULL OR revalidated_at < ?", cutoff)
        .where.not(state: %w[superseded deleted]) # We don't care if editions are invalid if they're superseded
    }
  end
end
