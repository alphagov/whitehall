class SitewideSetting < ActiveRecord::Base
  validates :govspeak, presence: true, if: :on
  validates :key, presence: true
  validates_uniqueness_of :key

  def human_status
    on ? "On" : "Off"
  end

  def name
    key.humanize
  end

end
