class StatisticalDataSet < Publicationesque
  include Edition::DocumentSeries
  include Edition::AlternativeFormatProvider

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
    if new_record? && access_limited.nil?
      self.access_limited = self.class.access_limited_by_default?
    end
  end
end
