class CreateEditionUserAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :edition_user_accesses do |t|
      t.references :edition, type: :integer, null: false, foreign_key: true
      t.string :email, null: false
      t.boolean :locked, null: false, default: false
      t.timestamps
    end

    add_index :edition_user_accesses, %i[edition_id email], unique: true
  end
end
