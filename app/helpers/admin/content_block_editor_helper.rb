module Admin::ContentBlockEditorHelper
  def content_block_json_tag
    content_tag "script", type: "application/json", id: "content-blocks" do
      content_blocks.html_safe
    end
  end

  def content_blocks
    content_items = Services.publishing_api.get_content_items(
      { document_type: "content_block_pension", states: ["published"] }
    ).parsed_content["results"]

    content_items.to_json
  end
end
