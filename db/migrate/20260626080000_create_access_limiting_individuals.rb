class CreateAccessLimitingIndividuals < ActiveRecord::Migration[8.1]
  def change
    create_table :access_limiting_individuals do |t|
      t.references :edition, type: :integer, null: false, foreign_key: true
      t.string :email, null: false
      t.timestamps
    end

    add_index :access_limiting_individuals, %i[edition_id email], unique: true
  end
end
