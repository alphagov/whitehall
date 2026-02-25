module ConfigurableContentBlocks
  class DefaultString < BaseConfig
    include Renderable

  private

    def template_name
      "default_string"
    end
  end
end
