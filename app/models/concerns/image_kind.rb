module ImageKind
  extend ActiveSupport::Concern

  included do
    def image_kind
      attributes.fetch("image_kind", "default")
    end

    def image_kind_config
      @image_kind_config ||= Whitehall.image_kinds.fetch(image_kind)
    end
  end
end
