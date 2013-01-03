module ImportHelpers
  def run_last_import
    Import.last.perform
  end

  def with_import_csv_file(data)
    tf = Tempfile.new('csv_import')
    tf << data
    tf.close
    yield tf.path
    tf.unlink
  end
end

World(ImportHelpers)
