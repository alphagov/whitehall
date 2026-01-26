class AddOffsiteLinkParents < ActiveRecord::Migration[8.0]
  def change
    create_table :offsite_link_parents do |t|
      t.references :offsite_link, null: false
      t.references :parent, polymorphic: true, null: false
      t.timestamps
    end

    add_index :offsite_link_parents,
              %i[parent_type parent_id offsite_link_id],
              unique: true
  end
end
