class CreateEditionDependencies < ActiveRecord::Migration
  def change
    create_table :edition_dependencies do |t|
      t.references :dependant
      t.references :dependable, polymorphic: true
    end

    add_index :edition_dependencies, [:dependable_id, :dependable_type, :dependant_id],
      unique: true, name: 'index_edition_dependencies_on_dependable_and_dependant'
  end
end
