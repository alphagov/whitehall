class SitewideSetting < ApplicationRecord
  validates :govspeak, presence: true, if: :on
  validates :key, presence: true
  validates :key, uniqueness: true
  validates_with SafeHtmlValidator

  def human_status
    on ? "On" : "Off"
  end

  def name
    key.humanize
  end
end
