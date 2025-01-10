class Admin::Editions::HostContentUpdateEventComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(event)
    @event = event
  end

private

  attr_reader :event

  def block_type
    event.document_type
  end

  def block_name
    event.content_title.strip
  end

  def link_text
    "[View#{tag.span(" #{block_name}", class: 'govuk-visually-hidden')} in Content Block Manager]".html_safe
  end

  def time
    absolute_time(event.created_at)
  end

  def actor
    event.author ? linked_author(event.author, class: "govuk-link") : "User (removed)"
  end
end
