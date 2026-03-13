module Whitehall
  class ImageVersion
    attr_reader :name, :width, :height, :from_version, :prefixed_name, :prefixed_from_version

    def initialize(version_config, version_prefix: nil)
      @name = version_config.fetch("name")
      @width = version_config.fetch("width")
      @height = version_config.fetch("height")
      @from_version = version_config.fetch("from_version", nil)
      @prefixed_name = version_prefix ? "#{version_prefix}_#{@name}" : @name
      @prefixed_from_version = @from_version && version_prefix ? "#{version_prefix}_#{@from_version}" : @from_version
    end

    def deconstruct_keys(_keys)
      { name:, width:, height:, from_version: }
    end

    def resize_to_fill
      [width, height]
    end
  end

  class ImageKind
    attr_reader :name, :display_name, :valid_width, :valid_height, :embed_version, :versions

    def initialize(name, config)
      @name = name
      @display_name = config.fetch("display_name")
      @valid_width = config.fetch("valid_width")
      @valid_height = config.fetch("valid_height")
      @embed_version = config.fetch("embed_version", nil)
      version_prefix = config.fetch("version_prefix", false) ? name : nil
      @versions = config.fetch("versions").map { |version_config| ImageVersion.new(version_config, version_prefix:) }.freeze
    end

    def deconstruct_keys(_keys)
      { name:, display_name:, valid_width:, valid_height:, versions:, embed_version: }
    end

    def version_names
      versions.map(&:prefixed_name)
    end

    def display_name_without_dimensions
      display_name.split("(").first.strip
    end
  end

  class ImageKinds
    def self.build_image_kinds(hash)
      hash.to_h { |name, config| [name, ImageKind.new(name, config)] }.freeze
    end
  end
end
