class Government < ActiveRecord::Base
  DISTANT_FUTURE = Date.today + 100.years

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
    return if date.to_date > Date.today

    where('start_date <= ?', date).order(start_date: :desc).first
  end

  def current?
    self == Government.current
  end

  def overlaps?(other)
    !(is_before?(other) || is_after?(other))
  end

private

  def is_before?(other)
    starts_before?(other) && ends_before?(other)
  end

  def is_after?(other)
    starts_after?(other) && ends_after?(other)
  end

  def starts_before?(other)
    start_date < other.start_date
  end

  def ends_before?(other)
    (end_date || DISTANT_FUTURE) < other.start_date
  end

  def starts_after?(other)
    start_date > (other.end_date || DISTANT_FUTURE)
  end

  def ends_after?(other)
    (end_date || DISTANT_FUTURE) > (other.end_date || DISTANT_FUTURE)
  end

  def not_overlapping?
    self.class.all.each do |existing_government|
      next if self == existing_government

      if self.overlaps?(existing_government)
        errors.add(:base, "overlaps #{existing_government.name}:
          This government: #{self.start_date} -> #{self.end_date || DISTANT_FUTURE},
          existing government: #{existing_government.start_date} -> #{existing_government.end_date || DISTANT_FUTURE}
        ")
      end
    end
  end
end
