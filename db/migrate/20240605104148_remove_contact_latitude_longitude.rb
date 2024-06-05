class RemoveContactLatitudeLongitude < ActiveRecord::Migration[7.1]
  def change
    change_table :contacts, bulk: true do |t|
      t.remove :latitude, type: :decimal, precision: 15, scale: 10
      t.remove :longitude, type: :decimal, precision: 15, scale: 10
    end
  end
end
