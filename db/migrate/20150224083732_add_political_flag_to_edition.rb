class AddPoliticalFlagToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :political, :boolean, null:false, default: false
  end
end
