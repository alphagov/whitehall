class AddEditionIdToWorldwideOffices < ActiveRecord::Migration[7.0]
  def change
    add_reference :worldwide_offices, :edition, type: :integer, index: true, foreign_key: true
    add_reference :editions, :main_office, type: :integer
  end
end
