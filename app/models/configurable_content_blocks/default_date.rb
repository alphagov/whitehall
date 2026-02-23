module ConfigurableContentBlocks
  class DefaultDate
    include BaseConfig
    include Renderable
    attr_reader :edition, :path

    def initialize(edition, config, path)
      @edition = edition
      @config = config
      @path = path
    end

    def content
      @edition.block_content&.value_at(@path)
    end

  private

    def template_name
      "default_date"
    end
  end
end
