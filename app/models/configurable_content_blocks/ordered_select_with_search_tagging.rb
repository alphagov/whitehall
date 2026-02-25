module ConfigurableContentBlocks
  class OrderedSelectWithSearchTagging
    include BaseConfig
    include Renderable
    include Admin::TaggableContentHelper

    attr_reader :path, :edition

    def initialize(edition, config, path)
      @edition = edition
      @config = config
      @path = path
    end

    def container
      @config["container"]
    end

    def size
      @config["size"]
    end

    def value
      @edition.public_send(@path.to_a.last)
    end

  private

    def template_name
      "ordered_select_with_search_tagging"
    end
  end
end
