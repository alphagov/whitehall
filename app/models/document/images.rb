module Document::Images
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      @document.images.each do |a|
        document.images.create(a.attributes.except(:id))
      end
    end
  end

  included do
    has_many :images, foreign_key: "document_id", dependent: :destroy

    accepts_nested_attributes_for :images, reject_if: -> da { da.fetch(:image_data_attributes, {}).values.all?(&:blank?) }, allow_destroy: true

    add_trait Trait
  end
end