module ConfigurableContentBlocks
  class Govspeak < BaseBlock
    include Renderable

  private

    def template_name
      "govspeak"
    end
  end
end
