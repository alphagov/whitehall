module Edition::Scopes::FilterableByInvalid
  extend ActiveSupport::Concern

  included do
    scope :only_invalid_editions, lambda {
      where(revalidated_at: nil)
        .where.not(state: %w[superseded unpublished deleted]) # We don't care if editions are invalid if they're superseded
    }
  end
end
