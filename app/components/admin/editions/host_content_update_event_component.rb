class Admin::Editions::HostContentUpdateEventComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(event)
    @event = event
  end

private

  attr_reader :event

  def activity
    "#{event.content_title.strip} updated"
  end

  def time
    absolute_time(event.created_at)
  end

  def actor
    event.author ? linked_author(event.author, class: "govuk-link") : "User (removed)"
  end
end
