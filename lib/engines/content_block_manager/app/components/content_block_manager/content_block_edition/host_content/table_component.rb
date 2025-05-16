class ContentBlockManager::ContentBlockEdition::HostContent::TableComponent < ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent
private

  def head
    [super, { text: "Preview (Opens in new tab)" }].flatten
  end

  def row_for_content_item(content_item)
    [super(content_item), { text: preview_link(content_item) }].flatten
  end

  def title_row(content_item)
    { text: content_item.title }
  end

  def preview_link(content_item)
    link_to(preview_link_text(content_item),
            frontend_path(content_item), class: "govuk-link", target: "_blank", rel: "noopener")
  end

  def preview_link_text(content_item)
    sanitize [
      "Preview",
      tag.span("#{content_item.title} (opens in new tab)", class: "govuk-visually-hidden"),
    ].join(" ")
  end

  def frontend_path(content_item)
    helpers.content_block_manager.host_content_preview_content_block_manager_content_block_edition_path(id: content_block_edition.id, host_content_id: content_item.host_content_id, locale: content_item.host_locale)
  end
end
