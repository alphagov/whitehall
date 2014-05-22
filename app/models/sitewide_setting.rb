class SitewideSetting < ActiveRecord::Base
  attr_accessible :govspeak, :key, :on, :description
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
