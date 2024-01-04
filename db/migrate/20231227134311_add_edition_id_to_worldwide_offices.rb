class AddEditionIdToWorldwideOffices < ActiveRecord::Migration[7.0]
  def change
    add_reference :worldwide_offices, :edition, type: :integer, index: true, foreign_key: true, name: "index_worldwide_offices_on_edition_id"
  end
end
