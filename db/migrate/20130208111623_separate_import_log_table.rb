class SeparateImportLogTable < ActiveRecord::Migration
  class ImportLog < ActiveRecord::Base
    default_scope order('id ASC')

    def to_s
      if row_number.present?
        "Row #{row_number} - #{level}: #{message}"
      else
        message
      end
    end
  end

  class Import < ActiveRecord::Base
    has_many :import_logs
  end

  def up
    create_table :import_logs do |t|
      t.integer  "import_id"
      t.integer  "row_number"
      t.string   "level"
      t.text     "message"
      t.datetime "created_at"
    end

    i = 0
    puts "Converting logs..."
    Import.find_each do |import|
      import.log.split("\n").each do |error|
        if match = error.match(/^Row ([0-9]+|-) - ([a-zA-Z]+): (.*)$/)
          row_number = (match[1] == '-' ? nil : match[1].to_i)
          log_level = match[2]
          message = match[3]
          import.import_logs.create(row_number: row_number, level: log_level, message: message)
        else
          import.import_logs.create(message: error)
        end

        i+=1
        if (i%500) == 0
          print "."
        end
      end
    end

    remove_column :imports, :log
  end

  def down
    add_column :imports, :log, :text, limit: (4.gigabytes - 1)
    Import.find_each do |import|
      import.update_column(:log, import.import_logs.map(&:to_s).join("\n"))
    end
  end
end
