class CreateSectorActivityJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :activities, :sectors
  end
end
