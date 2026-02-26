module ConfigurableContentBlocks
  class DefaultString < BaseBlock
    include Renderable

  private

    def template_name
      "default_string"
    end
  end
end
