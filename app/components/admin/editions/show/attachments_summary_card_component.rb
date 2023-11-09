# frozen_string_literal: true

class Admin::Editions::Show::AttachmentsSummaryCardComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def rows
    @edition.attachments.map do |attachment|
      {
        key: attachment.title,
        value: "#{attachment.readable_type.upcase_first} attachment",
        actions: row_actions(attachment),
      }
    end
  end

  def summary_card_actions
    if @edition.editable?
      [
        {
          label: "Manage attachments",
          href: admin_edition_attachments_path(@edition),
        },
      ]
    else
      []
    end
  end

private

  def row_actions(attachment)
    if @edition.editable?
      [
        {
          label: "View",
          href: attachment.url(full_url: true),
        },
        {
          label: "Edit",
          href: edit_admin_edition_attachment_path(@edition, attachment),
        },
      ]
    else
      [
        {
          label: "View",
          href: attachment.url(full_url: true),
        },
      ]
    end
  end
end
