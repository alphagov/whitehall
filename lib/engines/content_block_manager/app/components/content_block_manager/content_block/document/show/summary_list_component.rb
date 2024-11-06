class ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent < ViewComponent::Base
  def initialize(content_block_document:)
    @content_block_document = content_block_document
  end

private

  attr_reader :content_block_document

  def items
    [
      title_item,
      *details_items,
      organisation_item,
      creator_item,
      embed_code_item,
      state_item,
      scheduled_item,
    ].compact
  end

  def embed_code_item
    {
      field: "Embed code",
      value: content_block_document.embed_code,
      data: {
        module: "copy-embed-code",
        "embed-code": content_block_document.embed_code,
      },
    }
  end

  def title_item
    {
      field: "Title",
      value: content_block_document.title,
      edit: edit_action,
    }
  end

  def organisation_item
    {
      field: "Lead organisation",
      value: content_block_document.latest_edition.lead_organisation,
      edit: edit_action,
    }
  end

  def details_items
    content_block_document.latest_edition.details.map do |key, value|
      {
        field: key.humanize,
        value:,
        edit: edit_action,
      }
    end
  end

  def creator_item
    {
      field: "Creator",
      value: content_block_document.latest_edition.creator.name,
    }
  end

  def state_item
    {
      field: "State",
      value: content_block_document.latest_edition.state.titleize,
    }
  end

  def scheduled_item
    if content_block_document.latest_edition.state == "scheduled"
      {
        field: "Scheduled for publication at",
        value: I18n.l(content_block_document.latest_edition.scheduled_publication, format: :long_ordinal),
      }
    end
  end

  def edit_action
    {
      href: helpers.content_block_manager.new_content_block_manager_content_block_document_edition_path(content_block_document),
      link_text: "Change",
    }
  end
end
