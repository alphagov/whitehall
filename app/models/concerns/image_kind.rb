module ImageKind
  extend ActiveSupport::Concern

  included do
    def image_kind
      "default"
    end

    def image_kind_config
      @image_kind_config ||= Whitehall.image_kinds.fetch(self.image_kind)
    end
  end
end
