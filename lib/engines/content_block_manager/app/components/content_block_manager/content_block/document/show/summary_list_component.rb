class ContentBlockManager::ContentBlock::Document::Show::SummaryListComponent < ViewComponent::Base
  def initialize(content_block_document:)
    @content_block_document = content_block_document
  end

private

  attr_reader :content_block_document

  def items
    [
      edit_item,
      title_item,
      *details_items,
      organisation_item,
      instructions_item,
      status_item,
      embed_code_item,
    ].compact
  end

  def edit_item
    {
      field: "#{content_block_document.block_type.humanize} details",
      edit: edit_action,
    }
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
    }
  end

  def organisation_item
    {
      field: "Lead organisation",
      value: content_block_document.latest_edition.lead_organisation,
    }
  end

  def instructions_item
    {
      field: "Instructions to publishers",
      value: content_block_document.latest_edition.instructions_to_publishers.presence || "None",
    }
  end

  def details_items
    content_block_document.latest_edition.details.map do |key, value|
      {
        field: key.humanize,
        value:,
      }
    end
  end

  def status_item
    if content_block_document.latest_edition.state == "scheduled"
      {
        field: "Status",
        value: scheduled_value,
        edit: {
          href: helpers.content_block_manager.content_block_manager_content_block_document_schedule_edit_path(content_block_document),
          link_text: sanitize("Edit <span class='govuk-visually-hidden'>schedule</span>"),
          link_text_no_enhance: true,
        },
      }
    else
      {
        field: "Status",
        value: last_updated_value,
      }
    end
  end

  def last_updated_value
    "Published #{time_ago_in_words(content_block_document.latest_edition.updated_at)} ago by #{content_block_document.latest_edition.creator.name}"
  end

  def scheduled_value
    "Scheduled for publication at #{I18n.l(content_block_document.latest_edition.scheduled_publication, format: :long_ordinal)}"
  end

  def edit_action
    {
      href: helpers.content_block_manager.new_content_block_manager_content_block_document_edition_path(content_block_document),
      link_text: "Edit",
    }
  end
end
