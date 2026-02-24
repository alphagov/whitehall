module ConfigurableContentBlocks
  class DefaultObject
    include BaseConfig
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

    def fields
      @config["fields"]
    end

  private

    def template_name
      "default_object"
    end
  end
end
