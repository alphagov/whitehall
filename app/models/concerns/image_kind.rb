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
      raise MissingKindError if image_kind.nil?

      @image_kind_config ||= Whitehall.image_kinds.fetch(image_kind)
    end

    def crop
      return if crop_data.blank?

      @crop ||= Crop.new(*crop_data.values, crop_data_width.to_f / image_kind_config.valid_width)
    end
  end

  class Crop
    attr_reader :x, :y, :height, :width, :scale

    def initialize(left, top, width, height, scale)
      @x = left
      @y = top
      @height = height.to_f
      @width = width.to_f
      @scale = scale
    end

    def relative_x_to_width(width)
      relative_coord_to_value(focal_x, width)
    end

    def relative_y_to_height(height)
      relative_coord_to_value(focal_y, height)
    end

  private

    def focal_x
      focal_coord(@x, @width)
    end

    def focal_y
      focal_coord(@y, @height)
    end

    def focal_coord(coord, dimension)
      coord.to_f + (dimension.to_f / 2)
    end

    def relative_coord_to_value(coord, value)
      coord - ((value.to_f * scale) / 2)
    end
  end

  class MissingKindError < RuntimeError
  end
end
