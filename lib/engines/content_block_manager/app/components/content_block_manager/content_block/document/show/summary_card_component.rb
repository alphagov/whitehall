class ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponent < ViewComponent::Base
  def initialize(content_block_document:)
    @content_block_document = content_block_document
  end

private

  attr_reader :content_block_document

  def rows
    [
      title_item,
      *details_items,
      organisation_item,
      instructions_item,
      status_item,
      embed_code_item,
    ].compact
  end

  def title
    "#{content_block_document.block_type.humanize} details"
  end

  def embed_code_item
    {
      key: "Embed code",
      value: content_block_document.embed_code,
      data: {
        module: "copy-embed-code",
        "embed-code": content_block_document.embed_code,
      },
    }
  end

  def title_item
    {
      key: "Title",
      value: content_block_document.title,
    }
  end

  def organisation_item
    {
      key: "Lead organisation",
      value: content_block_edition.lead_organisation,
    }
  end

  def instructions_item
    {
      key: "Instructions to publishers",
      value: content_block_edition.instructions_to_publishers.presence || "None",
    }
  end

  def details_items
    content_block_edition.details.map do |key, value|
      {
        key: key.humanize,
        value:,
      }
    end
  end

  def status_item
    if content_block_edition.state == "scheduled"
      {
        key: "Status",
        value: scheduled_value,
        actions: [
          {
            label: sanitize("Edit <span class='govuk-visually-hidden'>schedule</span>"),
            href: helpers.content_block_manager.content_block_manager_content_block_document_schedule_edit_path(content_block_document),
          },
        ],
      }
    else
      {
        key: "Status",
        value: last_updated_value,
      }
    end
  end

  def last_updated_value
    "Published #{time_ago_in_words(content_block_edition.updated_at)} ago by #{content_block_edition.creator.name}"
  end

  def scheduled_value
    "Scheduled for publication at #{I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)}"
  end

  def content_block_edition
    @content_block_edition = content_block_document.latest_edition
  end
end
