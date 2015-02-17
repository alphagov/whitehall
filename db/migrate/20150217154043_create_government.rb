class CreateGovernment < ActiveRecord::Migration
  def up
    create_table :governments do |t|
      t.string :slug
      t.string :name
      t.date :start_date
      t.date :end_date
      t.timestamps
    end

    add_index :governments, :slug, unique: true
    add_index :governments, :name, unique: true
    add_index :governments, :start_date
    add_index :governments, :end_date
  end

  def down
    drop_table :governments
  end
end
