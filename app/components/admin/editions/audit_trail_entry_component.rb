# frozen_string_literal: true

class Admin::Editions::AuditTrailEntryComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :entry, :edition

  def initialize(entry:, edition:)
    @entry = entry
    @edition = edition
  end

private

  def action
    "Document #{entry.action}"
  end

  def actor
    entry.actor ? linked_author(entry.actor, class: "govuk-link") : "User (removed)"
  end

  def time
    absolute_time(entry.created_at)
  end

  def compare_with_previous_version?
    entry.action == "published" && edition.id != entry.version.item_id
  end
end
