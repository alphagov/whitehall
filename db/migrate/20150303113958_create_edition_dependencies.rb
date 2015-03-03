class CreateEditionDependencies < ActiveRecord::Migration
  def change
    create_table :edition_dependencies do |t|
      t.references :dependant
      t.references :dependable, polymorphic: true
    end

    add_index :edition_dependencies, [:dependant_id, :dependable_id, :dependable_type],
      unique: true, name: 'index_edition_dependencies_on_dependant_and_dependable'
  end
end
