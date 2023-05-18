class AddContentIdToWorldwideOffices < ActiveRecord::Migration[7.0]
  def up
    unless column_exists? :worldwide_offices, :content_id
      add_column :worldwide_offices, :content_id, :string
    end
  end

  def down
    remove_column :worldwide_offices, :content_id, :string
  end
end
