class Government < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :start_date, presence: true

  validate :not_overlapping?

  before_validation on: :create do |government|
    government.slug = government.name.to_s.parameterize
  end

  def self.current
    order(start_date: :desc).first
  end

  def self.on_date(date)
    return if date.to_date > Time.zone.today

    where('start_date <= ?', date).order(start_date: :asc).last
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
    self.ended? && end_date <= other.start_date
  end

  def starts_after?(other)
    other.ended? && start_date >= other.end_date
  end

  def ends_after?(other)
    return true unless self.ended?

    other.ended? && end_date > other.end_date
  end

  def not_overlapping?
    self.class.all.each do |existing_government|
      next if self == existing_government

      if self.overlaps?(existing_government)
        errors.add(:base, "overlaps #{existing_government.name}:
          Your new government: #{self.start_date} -> #{self.end_date || "present"},
          overlapping government: #{existing_government.start_date} -> #{existing_government.end_date || "present"}
        ")
      end
    end
  end
end
