class SitewideSetting < ActiveRecord::Base
  validates :key, presence: true
  validates_uniqueness_of :key
  validates_with SafeHtmlValidator

  def human_status
    on ? "On" : "Off"
  end

  def name
    key.humanize
  end

  def self.set(key, on)
    flag = find_by_key_or_create(key)
    flag.update(on: on)
  end

  def self.on?(name)
    if flag = find_by(key: name)
      flag.on
    else
      false
    end
  end

  def self.find_by_key_or_create(key)
    find_by(key: key) || create(key: key)
  end
end
