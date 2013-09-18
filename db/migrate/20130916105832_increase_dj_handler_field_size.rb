class IncreaseDjHandlerFieldSize < ActiveRecord::Migration
  def up
    # Bump column to MEDIUMTEXT
    change_column :delayed_jobs, :handler, :text, limit: 16777215
  end

  def down
    change_column :delayed_jobs, :handler, :text
  end
end
