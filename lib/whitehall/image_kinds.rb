module Whitehall
  class ImageVersion
    attr_reader :name, :width, :height, :from_version

    def initialize(version_config)
      @name = version_config.fetch("name")
      @width = version_config.fetch("width")
      @height = version_config.fetch("height")
      @from_version = version_config.fetch("from_version", nil)
    end

    def deconstruct_keys(_keys)
      { name:, width:, height:, from_version: }
    end

    def resize_to_fill
      [width, height]
    end
  end

  class ImageKind
    attr_reader :name, :display_name, :valid_width, :valid_height, :permitted_uses, :versions

    def initialize(name, config)
      @name = name
      @display_name = config.fetch("display_name")
      @valid_width = config.fetch("valid_width")
      @valid_height = config.fetch("valid_height")
      @permitted_uses = config.fetch("permitted_uses")
      @versions = config.fetch("versions").map { |version_config| ImageVersion.new(version_config) }.freeze
    end

    def deconstruct_keys(_keys)
      { name:, display_name:, valid_width:, valid_height:, permitted_uses:, versions: }
    end

    def version_names
      versions.map(&:name)
    end

    def permits?(use_case)
      permitted_uses.include?(use_case)
    end
  end

  class ImageKinds
    def self.build_image_kinds(hash)
      hash.to_h { |name, config| [name, ImageKind.new(name, config)] }.freeze
    end
  end
end
