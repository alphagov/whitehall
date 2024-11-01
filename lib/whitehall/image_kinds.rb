module Whitehall
  class ImageVersion
    attr_reader :name, :width, :height, :from_version

    def initialize(version_config)
      @name = version_config.fetch("name")
      @width = version_config.fetch("width")
      @height = version_config.fetch("height")
      @from_version = version_config.fetch("height", nil)
    end

    def resize_to_fill
      [width, height]
    end
  end

  class ImageKind
    attr_reader :name, :valid_width, :valid_height, :versions

    def initialize(name, config)
      @name = name
      @valid_width = config.fetch("valid_width")
      @valid_height = config.fetch("valid_height")
      @versions = config.fetch("versions").map { |version_config| ImageVersion.new(version_config) }.freeze
    end
  end

  class ImageKinds
    def self.build_image_kinds(hash)
      hash.map { |name, config| ImageKind.new(name, config) }.freeze
    end
  end
end