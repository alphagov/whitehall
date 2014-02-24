module AnalyticsIdentifierPopulator

  def self.included(base)
    base.class_eval do
      cattr_accessor :analytics_prefix
      after_create :ensure_analytics_identifier
    end
  end

  def ensure_analytics_identifier
    raise "#{self.class.name} must assign a value to attribute analytics_prefix" if self.analytics_prefix.nil?
    update_column(:analytics_identifier, self.analytics_prefix + id.to_s) if analytics_identifier.blank?
  end

end
