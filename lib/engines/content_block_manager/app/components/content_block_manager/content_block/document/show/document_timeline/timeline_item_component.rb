class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::TimelineItemComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper

  def initialize(version:, is_first_published_version:, is_latest:)
    @version = version
    @is_first_published_version = is_first_published_version
    @is_latest = is_latest
  end

private

  attr_reader :version, :is_first_published_version, :is_latest

  def title
    case version.state
    when "published"
      is_first_published_version ? "#{version.item.block_type.humanize} created" : version.state.capitalize
    when "scheduled"
      "Scheduled for publishing on #{version.item.scheduled_publication.to_fs(:long_ordinal_with_at)}"
    else
      "#{version.item.block_type.humanize} #{version.state}"
    end
  end

  def date
    tag.time(
      version.created_at.to_fs(:long_ordinal_with_at),
      class: "date",
      datetime: version.created_at.iso8601,
      lang: "en",
    )
  end

  def byline
    User.find_by_id(version.whodunnit)&.then { |user| helpers.linked_author(user, { class: "govuk-link" }) } || "unknown user"
  end

  def internal_change_note
    version.item.internal_change_note
  end

  def change_note
    version.item.change_note
  end
end
