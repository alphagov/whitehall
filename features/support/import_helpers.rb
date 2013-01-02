module ImportHelpers
  def run_last_import
    Import.last.perform
  end

  def with_import_csv_file(table)
    tf = Tempfile.new('csv_import')
    data = CSV.generate do |csv|
      table.raw.each { |r| csv << r }
    end
    tf << data
    tf.close
    yield tf.path
    tf.unlink
  end
end

World(ImportHelpers)
