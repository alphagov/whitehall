class CreateNamedAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :named_accesses do |t|
      t.references :edition, type: :integer, null: false, foreign_key: true
      t.string :email, null: false
      t.timestamps
    end

    add_index :named_accesses, %i[edition_id email], unique: true
  end
end
