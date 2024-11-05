module ImageKind
  extend ActiveSupport::Concern

  included do
    def assign_attributes(attributes)
      # It's important that the image_kind attribute is assigned first, as it is intended to be used by
      # carrierwave uploaders when they are mounted to work out which image versions to use.
      image_kind = attributes.delete(:image_kind)
      ordered_attributes = if image_kind.present?
                             { image_kind:, **attributes }
                           else
                             attributes
                           end
      super ordered_attributes
    end

    def image_kind
      attributes.fetch("image_kind", "default")
    end

    def image_kind_config
      @image_kind_config ||= Whitehall.image_kinds.fetch(image_kind)
    end
  end
end
