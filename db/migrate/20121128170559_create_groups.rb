class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups, :force => true do |t|
      t.references :organisation
      t.string :name
      t.timestamps
    end
    add_index :groups, :organisation_id
  end
end