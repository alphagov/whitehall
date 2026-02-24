module ConfigurableContentBlocks
  class DefaultString
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

    def primary_locale_content
      return nil if @edition.primary_locale.to_sym == @edition.translation_locale

      @edition.block_content(@edition.primary_locale.to_sym)&.value_at(@path)
    end

  private

    def template_name
      "default_string"
    end
  end
end
