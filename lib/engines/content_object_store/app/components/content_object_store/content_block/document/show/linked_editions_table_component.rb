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
          text: content_item["document_type"],
        },
        {
          text: organisation_link(content_item["publishing_organisation"]),
        },
      ]
    end
  end

  def content_link(content_item)
    # TODO: The base path 404s eg /government/publications/2
    # The admin equivalant works eg /government/admin/publications/2
    # Where do we expect these links to do, the admin view or the public view?
    link_to(content_item["title"], content_item["base_path"], class: "govuk-link")
  end

  def organisation_link(publishing_organisation)
    return nil if publishing_organisation.empty?

    link_to(publishing_organisation["title"], publishing_organisation["base_path"], class: "govuk-link")
  end
end
