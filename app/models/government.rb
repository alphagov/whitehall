class Government < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :start_date, presence: true

  before_validation on: :create do |government|
    government.slug = government.name.to_s.parameterize
  end

  def self.current
    order(start_date: :desc).first
  end

  def self.on_date(date)
    return if date.to_date > Date.today

    where('start_date <= ?', date).order(start_date: :desc).first
  end

  def current?
    self == Government.current
  end
end
