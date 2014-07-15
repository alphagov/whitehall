class IncreaseLinksLimit < ActiveRecord::Migration
  def up
    change_column :links_reports, :links, :text, limit: 16.megabytes - 1
  end

  def down
    change_column :links_reports, :links, :text, limit: 64.kilobytes - 1
  end
end
