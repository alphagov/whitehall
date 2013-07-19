class PopulateSummariesForPolicies < ActiveRecord::Migration
  class DocumentTable < ActiveRecord::Base
    self.table_name = "documents"
  end
  class PolicyTable < DocumentTable
  end

  def up
    ActiveRecord::Base.record_timestamps = false
    PolicyTable.all.each do |p|
      p.update_column(:summary, summary_from(p.body))
    end
    ActiveRecord::Base.record_timestamps = true
  end

  def down
    PolicyTable.all.each { |p| p.update_column(:summary, nil) }
  end

  def summary_from(string)
    text = string.gsub(/^#+.*\n/, "").gsub(/^[^\n]+\n[=-]+\n/, "").gsub(/\n\s*\n/, " ").strip
    text[0,150].gsub(/\s\w+$/, "")
  end
end
