class Government < ApplicationRecord
  include PublishesToPublishingApi

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :content_id, presence: true, uniqueness: { case_sensitive: false }
  validates :start_date, presence: true

  validate :not_overlapping?, if: -> { start_date.present? }

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

  def overlaps?(other)
    !before?(other) && !after?(other)
  end

  def ended?
    end_date.present?
  end

  def publishing_api_presenter
    PublishingApi::GovernmentPresenter
  end

private

  def before?(other)
    starts_before?(other) && ends_before?(other)
  end

  def after?(other)
    starts_after?(other) && ends_after?(other)
  end

  def starts_before?(other)
    start_date < other.start_date
  end

  def ends_before?(other)
    ended? && end_date <= other.start_date
  end

  def starts_after?(other)
    other.ended? && start_date >= other.end_date
  end

  def ends_after?(other)
    return true unless ended?

    other.ended? && end_date > other.end_date
  end

  def not_overlapping?
    self.class.all.find_each do |existing_government|
      next if self == existing_government

      if overlaps?(existing_government)
        errors.add(
          :base,
          "overlaps #{existing_government.name}:
          Your new government: #{start_date} -> #{end_date || 'present'},
          overlapping government: #{existing_government.start_date} -> #{existing_government.end_date || 'present'}
        ",
        )
      end
    end
  end
end
