# frozen_string_literal: true

class Admin::Editions::AuditTrailEntryComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :entry

  def initialize(entry:)
    @entry = entry
  end

private

  def action
    "#{entry.action.capitalize} by "
  end

  def actor
    entry.actor ? linked_author(entry.actor, class: "govuk-link") : "User (removed)"
  end

  def time
    absolute_time(entry.created_at)
  end
end
