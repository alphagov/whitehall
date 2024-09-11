class Government < ApplicationRecord
  include DateValidation
  include PublishesToPublishingApi

  date_attributes(:start_date, :end_date)

  scope :newest_first, -> { order(start_date: :desc) }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :content_id, presence: true, uniqueness: { case_sensitive: false }
  validates :start_date, presence: true

  before_validation on: :create do |government|
    government.slug = government.name.to_s.parameterize
  end

  def self.current
    order(start_date: :desc).first
  end

  def self.on_date(date)
    return if date.to_date > Time.zone.today

    where("start_date <= ?", date).order(start_date: :asc).last
  end

  def current?
    self == Government.current
  end

  def ended?
    end_date.present?
  end

  def publishing_api_presenter
    PublishingApi::GovernmentPresenter
  end
end
