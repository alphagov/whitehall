# frozen_string_literal: true

class Admin::Editions::Show::TopicTagsSummaryCardComponent < ViewComponent::Base
  def initialize(edition:, edition_taxons:)
    @edition = edition
    @edition_taxons = edition_taxons
  end

  def summary_card_actions
    [
      {
        label: "Manage tags",
        href: edit_admin_edition_tags_path(@edition.id),
      },
    ]
  end
end
