# frozen_string_literal: true

class Admin::Editions::PublishingPrerequisitesComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def render?
    edition.pre_publication? && messages.any?
  end

private

  attr_reader :edition

  def messages
    @messages ||= edition.try(:unmet_publishing_prerequisites) || []
  end
end
