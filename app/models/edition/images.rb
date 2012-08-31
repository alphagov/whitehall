module Edition::Images
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      @edition.images.each do |a|
        edition.images.create(a.attributes.except(:id))
      end
    end
  end

  included do
    has_many :images, foreign_key: "edition_id", dependent: :destroy

    accepts_nested_attributes_for :images, reject_if: :no_substantive_attributes?, allow_destroy: true

    def no_substantive_attributes?(attrs)
      attrs.except(:image_data_attributes, :_destroy).values.all?(&:blank?) &&
        (attrs[:image_data_attributes] || {}).values.all?(&:blank?)
    end
    private :no_substantive_attributes?

    add_trait Trait
  end

  def lead_image
    nil
  end

  def allows_image_attachments?
    true
  end
end