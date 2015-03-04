class AddPoliticalToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :political, :boolean, default: false
  end
end
