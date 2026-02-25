module ConfigurableContentBlocks
  class Govspeak < BaseConfig
    include Renderable

  private

    def template_name
      "govspeak"
    end
  end
end
