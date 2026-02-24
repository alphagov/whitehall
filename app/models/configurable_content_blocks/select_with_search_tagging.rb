module ConfigurableContentBlocks
  class SelectWithSearchTagging
    include BaseConfig
    include Renderable
    include Admin::TaggableContentHelper
    attr_reader :edition, :path

    def initialize(edition, config, path)
      @edition = edition
      @config = config
      @path = path
    end

    def container
      @config["container"]
    end

    def value
      @edition.public_send(@path.to_a.last)
    end

  private

    def template_name
      "select_with_search_tagging"
    end
  end
end
