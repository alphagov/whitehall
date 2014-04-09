 module HasFeaturedLinks
  extend ActiveSupport::Concern

  module ClassMethods
    def has_featured_links(feature_type)
      has_many feature_type, as: :linkable, dependent: :destroy, order: :created_at
      accepts_nested_attributes_for feature_type, reject_if: -> attributes { attributes['url'].blank? }, allow_destroy: true
    end
  end
end
