class AddStatusIncorrectFieldToWorldLocation < ActiveRecord::Migration[6.1]
  def change
    change_table :world_locations, bulk: true do |t|
      t.boolean :coronavirus_status_out_of_date, default: false
    end
  end
end
