class CreateImportErrors < ActiveRecord::Migration
  class Import < ActiveRecord::Base
    serialize :import_errors
  end

  class ImportError < ActiveRecord::Base
  end

  def up
    create_table :import_errors do |t|
      t.references :import
      t.integer :row_number
      t.string :message
      t.datetime :created_at
    end
    add_index :import_errors, :import_id

    Import.all.each do |import|
      import.import_errors.each do |import_error|
        ImportError.create(import_id: import.id, row_number: import_error[:row_number], message: import_error[:message])
      end
    end

    remove_column :imports, :import_errors
  end

  def down
    add_column :imports, :import_errors, :text, limit: (4.gigabytes - 1)
    Import.all.each do |import|
      import.import_errors = ImportError.where(import_id: import.id).map do |e|
        {row_number: e.row_number, message: e.message}
      end
      import.save
    end
    drop_table :import_errors
  end
end
