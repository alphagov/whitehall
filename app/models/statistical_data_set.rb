class StatisticalDataSet < Edition
  include Edition::DocumentSeries
  include ::Attachable
  include Edition::AlternativeFormatProvider

  attachable :edition

  after_initialize :set_access_limited

  def allows_attachment_references?
    true
  end

  def can_have_summary?
    true
  end

  def can_limit_access?
    true
  end

  private

  def self.access_limited_by_default?
    true
  end

  def set_access_limited
    self.access_limited = self.class.access_limited_by_default? if access_limited.nil?
  end
end