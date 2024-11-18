module Edition::Images
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      @edition.images.each do |a|
        image = edition.images.build(a.attributes.except("id"))
        if image.invalid?
          Rails.logger.warn "Ignoring errors on saving image for edition with id #{edition.id}: #{image.errors.full_messages.join(', ')}"
        end
        image.save!(validate: false)

        next unless @edition.can_have_custom_lead_image?

        if @edition.lead_image == a
          edition_lead_image = edition.build_edition_lead_image(image:)
          edition_lead_image.save!
        end
      end
    end
  end

  included do
    has_many :images, foreign_key: "edition_id", dependent: :destroy

    accepts_nested_attributes_for :images, reject_if: :no_substantive_attributes?, allow_destroy: true

    add_trait Trait

    def images_uploaded_to_asset_manager?
      images
        .map(&:image_data)
        .compact
        .all?(&:all_asset_variants_uploaded?)
    end
  end

  def allows_image_attachments?
    true
  end

  def permitted_image_kinds
    Whitehall.image_kinds.values_at("default")
  end

private

  def no_substantive_attributes?(attrs)
    attrs.except(:image_data_attributes, :_destroy).values.all?(&:blank?) &&
      (attrs[:image_data_attributes] || {}).values.all?(&:blank?)
  end
end
