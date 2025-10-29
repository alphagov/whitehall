# frozen_string_literal: true

class Admin::Editions::FirstPublishedAtComponent < ViewComponent::Base
  include ErrorsHelper

  def initialize(edition:, previously_published:, day: nil, month: nil, year: nil)
    @edition = edition
    @previously_published = previously_published
    @day = day
    @month = month
    @year = year
  end

private

  attr_reader :edition, :previously_published, :day, :month, :year

  def document_has_never_been_published?
    edition.published_major_version.nil?
  end

  def first_published_at_fields
    render("components/datetime_fields", {
      ga4_form_section: "First published date",
      field_name: "first_published_at",
      prefix: "edition",
      date_heading: "Date (required)",
      date_only: true,
      date_hint: "For example, 01 08 2022",
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
    })
  end
end
