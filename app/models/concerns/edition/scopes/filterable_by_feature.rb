module Edition::Scopes::FilterableByFeature
  extend ActiveSupport::Concern

  included do
    scope :excluding_featured_on, lambda { |feature_list|
      where.not(
        document_id: feature_list.features.current.where.not(document_id: nil).select(:document_id),
      )
    }
  end
end
