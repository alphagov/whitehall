module ConfigurableContentBlocks
  class DefaultDate < BaseBlock
    include Renderable

  private

    def template_name
      "default_date"
    end
  end
end
