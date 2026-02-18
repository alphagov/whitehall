module ConfigurableContentBlocks
  class DefaultObject
    include Renderable
    attr_reader :edition, :path

    def initialize(edition, config, path)
      @edition = edition
      @config = config
      @path = path
    end

    def root?
      @config["root"]
    end

    def title
      @config["title"]
    end

    def fields
      @config["fields"]
    end

    def required
      @config["required"]
    end

    private def template_name
      "default_object"
    end
  end
end
