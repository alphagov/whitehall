module Edition::Scopes::FilterableByFeature
  extend ActiveSupport::Concern

  included do
    scope :excluding_featured, lambda {
      where.not(
        document_id: Feature.current.where.not(document_id: nil).select(:document_id),
      )
    }
  end
end
