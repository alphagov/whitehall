module FinderHelpers
  def stub_content_item_from_content_store_for(base_path)
    @content_item = content_item_for_base_path(base_path)

    content_store_has_item(base_path, @content_item)
  end
end

World(FinderHelpers)
