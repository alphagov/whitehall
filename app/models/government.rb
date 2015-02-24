class Government < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :start_date, presence: true

  has_many :documents

  before_validation on: :create do |government|
    government.slug = government.name.to_s.parameterize
  end

  scope :current, -> { order(start_date: :desc).first }

  def self.on_date(date)
    return nil if date.to_date > Date.today
    self.where('start_date <= ?', date).order(start_date: :desc).first
  end
end
