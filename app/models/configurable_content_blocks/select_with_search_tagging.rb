module ConfigurableContentBlocks
  class SelectWithSearchTagging < BaseBlock
    include Renderable
    include Admin::TaggableContentHelper

    def container
      @config["container"]
    end

  private

    def template_name
      "select_with_search_tagging"
    end
  end
end
