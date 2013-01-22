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

  def import_data_as_document_type_for_organisation(data, document_type, organisation)
    make_sure_data_importer_user_exists
    Import.use_separate_connection

    with_import_csv_file(data) do |path|
      visit new_admin_import_path
      select document_type, from: 'Type'
      attach_file 'CSV File', path
      select organisation.name, from: 'Default organisation'
      click_button 'Save'
      click_button 'Run'

      run_last_import

      visit current_path
    end
    Import.find(current_path.match(/admin\/imports\/(\d+)\Z/)[1])
  end

  def make_sure_data_importer_user_exists
    unless User.find_by_name('Automatic Data Importer')
      create(:user, name: 'Automatic Data Importer')
    end
  end
end

World(ImportHelpers)
