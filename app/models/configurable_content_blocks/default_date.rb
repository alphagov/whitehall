module ConfigurableContentBlocks
  class DefaultDate < BaseConfig
    include Renderable

  private

    def template_name
      "default_date"
    end
  end
end
