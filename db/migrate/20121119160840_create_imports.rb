class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :original_filename
      t.string :data_type
      t.text :csv_data, limit: (4.gigabytes - 1)
      t.text :import_errors
      t.text :already_imported
      t.text :successful_rows
      t.integer :creator_id
      t.datetime :import_started_at
      t.datetime :import_finished_at
      t.integer :total_rows
      t.integer :current_row
      t.text :log, limit: (4.gigabytes - 1)

      t.timestamps
    end
  end
end
