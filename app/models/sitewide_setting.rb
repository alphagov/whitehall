class SitewideSetting < ApplicationRecord
  validates :govspeak, presence: true, if: :on
  validates :key, presence: true
  validates :key, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates_with SafeHtmlValidator

  after_save :republish_ministers_if_reshuffle

  def human_status
    on ? "On" : "Off"
  end

  def name
    key.humanize
  end

  def republish_ministers_if_reshuffle 
    return unless key == "minister_reshuffle_mode"

    payload = PublishingApi::MinistersIndexPresenter.new

    Services.publishing_api.put_content(payload.content_id, payload.content)
    Services.publishing_api.publish(payload.content_id, nil, locale: "en")
  end
end
