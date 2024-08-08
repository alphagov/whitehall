# frozen_string_literal: true

class ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponent < ViewComponent::Base
  def initialize(caption:, linked_content_items:)
    @caption = caption
    @linked_content_items = linked_content_items
  end

private

  attr_reader :caption, :linked_content_items

  def rows
    return [] unless linked_content_items

    linked_content_items.map do |content_item|
      [
        {
          text: content_link(content_item),
        },
        {
          text: content_item.document_type.humanize,
        },
        {
          text: organisation_link(content_item.organisation),
        },
      ]
    end
  end

  def content_link(content_item)
    link_to(content_item.title, Plek.website_root + content_item.base_path, class: "govuk-link")
  end

  def organisation_link(organisation)
    return nil if organisation.nil?

    link_to(organisation.name, admin_organisation_path(organisation), class: "govuk-link")
  end
end
