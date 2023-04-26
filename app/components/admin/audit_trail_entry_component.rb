class Admin::AuditTrailEntryComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :version

  def initialize(version:)
    @version = version
  end

private

  def action
    case version.event
    when "update" then "Document updated"
    when "create" then "Document created"
    when "initial" then "No history before this time"
    else "Unknown action"
    end
  end

  def actor
    return "User (unknown)" if version.whodunnit.nil?
    return "User (removed)" if version.user.nil?

    linked_author(version.user, class: "govuk-link")
  end

  def time
    absolute_time(version.created_at)
  end
end
