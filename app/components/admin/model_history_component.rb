class Admin::ModelHistoryComponent < ViewComponent::Base
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
    else "Unknown action"
    end
  end

  def actor
    user = version.user

    user ? linked_author(user, class: "govuk-link") : "User (removed)"
  end

  def time
    absolute_time(version.created_at)
  end
end
