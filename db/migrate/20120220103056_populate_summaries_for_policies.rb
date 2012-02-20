class PopulateSummariesForPolicies < ActiveRecord::Migration
  def up
    ActiveRecord::Base.record_timestamps = false
    Policy.all.each do |p|
      p.update_attribute(:summary, summary_from(p.body))
    end
    ActiveRecord::Base.record_timestamps = true
  end

  def down
    Policy.all.each { |p| p.update_attribute(:summary, nil) }
  end

  def summary_from(string)
    text = string.gsub(/^#+.*\n/, "").gsub(/^[^\n]+\n[=-]+\n/, "").gsub(/\n\s*\n/, " ").strip
    text[0,150].gsub(/\s\w+$/, "")
  end
end
