module Edition::Scopes::FilterableByInvalid
  extend ActiveSupport::Concern

  included do
    scope :only_invalid_editions, lambda {
      where(revalidation_passed: false)
        .where.not(state: "superseded") # We don't care if editions are invalid if they're superseded
    }
  end
end
