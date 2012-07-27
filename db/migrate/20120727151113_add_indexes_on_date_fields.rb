class AddIndexesOnDateFields < ActiveRecord::Migration
  def change
    add_index :editions, :publication_date
    add_index :editions, :first_published_at
  end
end
