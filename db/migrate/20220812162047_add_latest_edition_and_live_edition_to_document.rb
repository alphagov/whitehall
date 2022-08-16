class AddLatestEditionAndLiveEditionToDocument < ActiveRecord::Migration[7.0]
  def change
    change_table :documents, bulk: true do |t|
      fk_options = {
        to_table: :editions,
        on_delete: :nullify,
        on_update: :cascade,
      }

      t.references :latest_edition, foreign_key: fk_options, type: :integer
      t.references :live_edition, foreign_key: fk_options, type: :integer
    end
  end
end
