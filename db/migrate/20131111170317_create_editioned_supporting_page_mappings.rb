class CreateEditionedSupportingPageMappings < ActiveRecord::Migration
  def change
    create_table :editioned_supporting_page_mappings do |t|
      t.integer :old_supporting_page_id
      t.integer :new_supporting_page_id

      t.timestamps
    end

    add_index :editioned_supporting_page_mappings, :old_supporting_page_id, unique: true, name: "index_editioned_supporting_page_mappings"
  end
end
