# frozen_string_literal: true

class SocialMediaTabForm
  include ActiveModel::Model

  validate check_social_media_links

  def initialize(edition)
    @edition = edition
    @type_instance = edition.type_instance
  end

  private

  attr_reader :edition, :type_instance

  def check_social_media_links
    # TODO: implement actual validation based on what is in the config for this :type_instance
    errors.add(:social_media_links, :blank)
  end
end
