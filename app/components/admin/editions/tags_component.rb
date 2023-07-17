# frozen_string_literal: true

class Admin::Editions::TagsComponent < ViewComponent::Base
  BASE_TAG_CLASSES = "govuk-tag govuk-tag--s"

  def initialize(edition)
    @edition = edition
  end

private

  attr_reader :edition

  def tags
    sanitize(
      [
        state_tag,
        limited_access_tag,
        broken_links_report_tag,
      ]
      .compact
      .join(" "),
    )
  end

  def state_tag
    create_tag(state)
  end

  def limited_access_tag
    return unless edition.access_limited?

    create_tag("Limited access")
  end

  def broken_links_report_tag
    return unless edition.link_check_reports.any? && edition.link_check_reports.last.completed?

    return create_tag("Broken links") if edition.link_check_reports.last.broken_links.any?

    return create_tag("Link warnings") if edition.link_check_reports.last.caution_links.any?
  end

  def create_tag(label)
    tag.span(label, class: class_names([BASE_TAG_CLASSES] + [colour(label)]))
  end

  def state
    if edition.force_scheduled?
      "Force scheduled"
    elsif edition.force_published?
      "Force published"
    elsif edition.unpublishing.present? && !edition.withdrawn?
      "Unpublished"
    else
      edition.state.humanize
    end
  end

  def colour(label)
    case label
    when "Force published", "Link warnings", "Force scheduled"
      "govuk-tag--yellow"
    when "Draft"
      "govuk-tag--blue"
    when "Published"
      "govuk-tag--green"
    when "Scheduled"
      "govuk-tag--turquoise"
    when "Rejected", "Broken links", "Limited access"
      "govuk-tag--red"
    when "Withdrawn", "Unpublished"
      "govuk-tag--grey"
    end
  end
end
