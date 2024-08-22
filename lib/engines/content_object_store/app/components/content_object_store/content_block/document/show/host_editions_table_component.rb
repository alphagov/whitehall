# frozen_string_literal: true

class ContentObjectStore::ContentBlock::Document::Show::HostEditionsTableComponent < ViewComponent::Base
  def initialize(caption:, host_content_items:)
    @caption = caption
    @host_content_items = host_content_items
  end

private

  attr_reader :caption, :host_content_items

  def rows
    return [] unless host_content_items

    host_content_items.map do |content_item|
      [
        {
          text: content_link(content_item),
        },
        {
          text: content_item.document_type.humanize,
        },
        {
          text: organisation_link(content_item),
        },
      ]
    end
  end

  def content_link(content_item)
    link_to(content_item.title, Plek.website_root + content_item.base_path, class: "govuk-link")
  end

  def organisation_link(content_item)
    return nil if content_item.nil?

    matching_organisation = all_publishing_organisations.find_by_content_id(content_item.publishing_organisation["content_id"])
    if matching_organisation
      link_to(matching_organisation.name, admin_organisation_path(matching_organisation), class: "govuk-link")
    else
      content_item.publishing_organisation.fetch("title", nil)
    end
  end

  def all_publishing_organisations
    @all_publishing_organisations ||= begin
      host_content_ids = host_content_items.map { |content_item|
        content_item.publishing_organisation.fetch("content_id", nil)
      }.compact

      Organisation.where(content_id: host_content_ids)
    end
  end
end
