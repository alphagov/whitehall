# frozen_string_literal: true

class ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent < ViewComponent::Base
  def initialize(caption:, host_content_items:, is_preview: false)
    @caption = caption
    @host_content_items = host_content_items
    @is_preview = is_preview
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
          text: content_item.unique_pageviews ? number_to_human(content_item.unique_pageviews, format: "%n%u", precision: 3, significant: true, units: { thousand: "k", million: "m", billion: "b" }) : nil,
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

  # TODO: Currently, we're only fetching Users from the local Whitehall database, which means
  # content updated outside Whitehall with a `last_edited_by_editor_id` where the user
  # does not have Whitehall access will show up as an unknown user. We are looking to
  # fix this by possibly adding an endpoint to Signon, but this gets us part of the way
  # there. Card for this work is here: https://trello.com/c/jVvs4nAP/640-get-author-information-from-signon
  def users
    @users ||= User.where(uid: host_content_items.map(&:last_edited_by_editor_id))
  end

  def frontend_path(content_item)
    if @is_preview
      Plek.external_url_for("draft-origin") + content_item.base_path
    else
      Plek.external_url_for("government-frontend") + content_item.base_path
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
    last_updated_by_user = content_item.last_edited_by_editor_id && users.find { |u| u.uid == content_item.last_edited_by_editor_id }
    user_copy = last_updated_by_user ? mail_to(last_updated_by_user.email, last_updated_by_user.name, { class: "govuk-link" }) : "Unknown user"
    "#{time_ago_in_words(content_item.last_edited_at)} ago by #{user_copy}".html_safe
  end
end
