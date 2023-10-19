class AddLeadImageForeignKeyToEdition < ActiveRecord::Migration[7.0]
  def change
    change_table :editions, bulk: true do |t|
      fk_options = {
        to_table: :images,
        on_delete: :nullify,
        on_update: :cascade,
      }

      t.references :lead_image, foreign_key: fk_options, type: :integer
    end
  end
end
