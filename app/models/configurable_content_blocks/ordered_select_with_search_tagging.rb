module ConfigurableContentBlocks
  class OrderedSelectWithSearchTagging < BaseBlock
    include Renderable
    include Admin::TaggableContentHelper

    def container
      @config["container"]
    end

    def size
      @config["size"]
    end

  private

    def template_name
      "ordered_select_with_search_tagging"
    end
  end
end
