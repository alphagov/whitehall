# frozen_string_literal: true

class Admin::Editions::FirstPublishedAtComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(edition:, previously_published:, day: nil, month: nil, year: nil, hour: nil, minute: nil)
    @edition = edition
    @previously_published = previously_published
    @day = day
    @month = month
    @year = year
    @hour = hour
    @minute = minute
  end

private

  attr_reader :edition, :previously_published, :day, :month, :year, :hour, :minute

  def document_has_never_been_published?
    edition.published_major_version.nil?
  end

  def first_published_at_fields
    render("components/datetime_fields", {
      ga4_form_section: "First published date",
      field_name: "first_published_at",
      prefix: "edition",
      date_heading: "Date (required)",
      date_hint: "For example, 01 08 2022",
      time_heading: "Time (optional)",
      time_hint: "For example, 09:30 or 19:30",
      error_items: errors_for(edition.errors, :first_published_at),
      id: "edition_first_published_at",
      year: {
        id: "edition_first_published_at_1i",
        value: year,
        name: "edition[first_published_at(1i)]",
        label: "Year",
        width: 4,
      },
      month: {
        id: "edition_first_published_at_2i",
        value: month,
        name: "edition[first_published_at(2i)]",
        label: "Month",
        width: 2,
      },
      day: {
        id: "edition_first_published_at_3i",
        value: day,
        name: "edition[first_published_at(3i)]",
        label: "Day",
        width: 2,
      },
      hour: {
        id: "edition_first_published_at_4i",
        value: hour,
        name: "edition[first_published_at(4i)]",
        label: "Hour",
        width: 2,
      },
      minute: {
        id: "edition_first_published_at_5i",
        value: minute,
        name: "edition[first_published_at(5i)]",
        label: "Minute",
        width: 2,
      },
    })
  end
end
