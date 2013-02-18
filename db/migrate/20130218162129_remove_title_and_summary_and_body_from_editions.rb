class RemoveTitleAndSummaryAndBodyFromEditions < ActiveRecord::Migration
  def up
    remove_column :editions, :title
    remove_column :editions, :summary
    remove_column :editions, :body
  end

  def self.down
    add_column :editions, :body, :text, limit: 16.megabytes - 1
    add_column :editions, :summary, :text
    add_column :editions, :title, :string
  end
end
