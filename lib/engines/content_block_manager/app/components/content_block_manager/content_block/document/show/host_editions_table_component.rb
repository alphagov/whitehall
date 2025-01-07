# frozen_string_literal: true

class ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent < ViewComponent::Base
  TABLE_ID = "host_editions"

  def initialize(caption:, host_content_items:, content_block_edition:, is_preview: false, current_page: nil, order: nil)
    @caption = caption
    @host_content_items = host_content_items
    @is_preview = is_preview
    @current_page = current_page.presence || 1
    @order = order.presence || ContentBlockManager::GetHostContentItems::DEFAULT_ORDER
    @content_block_edition = content_block_edition
  end

  def current_page
    @current_page.to_i
  end

  def total_pages
    host_content_items.total_pages.to_i
  end

  def base_pagination_path
    "#{request.url}##{TABLE_ID}"
  end

private

  attr_reader :caption, :host_content_items, :order, :content_block_edition

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
          text: content_item.unique_pageviews ? number_to_human(content_item.unique_pageviews, format: "%n%u", precision: 3, significant: true, units: { thousand: "k", million: "m", billion: "b" }) : 0,
        },
        {
          text: content_item.instances,
        },
        {
          text: organisation_link(content_item),
        },
        {
          text: updated_field_for(content_item),
        },
      ]
    end
  end

  def sort_direction(param)
    case order
    when param
      "ascending"
    when "-#{param}"
      "descending"
    end
  end

  def sort_link(param)
    if sort_direction(param) == "ascending"
      param = "-#{param}"
    end
    helpers.content_block_manager.url_for(only_path: false, params: { order: param }, anchor: TABLE_ID)
  end

  def frontend_path(content_item)
    if @is_preview
      helpers.content_block_manager.content_block_manager_content_block_host_content_preview_path(id: content_block_edition.id, host_content_id: content_item.host_content_id)
    else
      Plek.website_root + content_item.base_path
    end
  end

  def content_link_text(content_item)
    sanitize [
      content_item.title,
      tag.span("(opens in new tab)", class: "govuk-visually-hidden"),
    ].join(" ")
  end

  def content_link(content_item)
    link_to(content_link_text(content_item),
            frontend_path(content_item), class: "govuk-link", target: "_blank", rel: "noopener")
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

  def updated_field_for(content_item)
    user_copy = content_item.last_edited_by_editor ? mail_to(content_item.last_edited_by_editor.email, content_item.last_edited_by_editor.name, { class: "govuk-link" }) : "Unknown user"
    "#{time_ago_in_words(content_item.last_edited_at)} ago by #{user_copy}".html_safe
  end
end
