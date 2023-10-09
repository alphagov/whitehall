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

  def render?
    !edition.is_a?(Consultation)
  end

private
  attr_reader :edition, :previously_published, :day, :month, :year
end
