class AddPublishedOnToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :published_on, :date
  end
end
