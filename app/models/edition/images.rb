module Edition::Images
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      @edition.images.each do |a|
        image = edition.images.build(a.attributes.except('id'))
        if image.invalid?
          Rails.logger.warn "Ignoring errors on saving image for edition with id #{edition.id}: #{image.errors.full_messages.join(', ')}"
        end
        image.save(validate: false)
      end
    end
  end

  included do
    has_many :images, foreign_key: "edition_id", dependent: :destroy

    accepts_nested_attributes_for :images, reject_if: :no_substantive_attributes?, allow_destroy: true

    add_trait Trait
  end

  def allows_image_attachments?
    true
  end

  private

  def no_substantive_attributes?(attrs)
    attrs.except(:image_data_attributes, :_destroy).values.all?(&:blank?) &&
      (attrs[:image_data_attributes] || {}).values.all?(&:blank?)
  end
end
