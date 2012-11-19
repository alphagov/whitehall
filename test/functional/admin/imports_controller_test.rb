require 'test_helper'

class Admin::ImportsControllerTest < ActionController::TestCase
  setup do
    login_as :importer
  end

  should_be_an_admin_controller

  test "new shows an interface to start a new import" do
    get :new
  end

  test "be able to upload a tagged CSV file" do
    csv_file = fixture_file_upload("dft_publication_import_with_json_test.csv")
    Import.expects(:create_from_file).with(anything, csv_file, "consultation").returns(new_import)
    post :create, import: {file: csv_file, data_type: "consultation"}
  end

  test "record the person who uploaded a CSV file" do
    csv_file = fixture_file_upload("dft_publication_import_with_json_test.csv")
    Import.expects(:create_from_file).with(current_user, anything, anything).returns(new_import)
    post :create, import: {file: csv_file}
  end

  test "should run the import on successful upload" do
    new_import.expects(:enqueue!)
    Import.stubs(:create_from_file).returns(new_import)
    post :create, import: {file: fixture_file_upload("dft_publication_import_with_json_test.csv")}
  end

  test "redirects to show on successful upload" do
    Import.stubs(:create_from_file).returns(new_import)
    post :create, import: {file: fixture_file_upload("dft_publication_import_with_json_test.csv")}
    assert_redirected_to admin_import_path(new_import)
  end

  test "show declares queued if queued" do
    import = stub_record(:import, creator: current_user)
    import.stubs(:status).returns(:queued)
    Import.stubs(:find).with(import.id.to_s).returns(import)

    get :show, id: import

    assert_select record_css_selector(import) do
      assert_select ".summary", /Import queued/
    end
  end

  test "show shows declares success on success" do
    import = stub_record(:import, creator: current_user)
    import.stubs(:status).returns(:success)
    Import.stubs(:find).with(import.id.to_s).returns(import)

    get :show, id: import

    assert_select record_css_selector(import) do
      assert_select ".summary", /Imported successfully/
    end
  end

  test "show shows errors if any" do
    import = stub_record(:import, import_errors: [{row_number: 1, message: "Policy 'blah' does not exist"}],
      creator: current_user)
    import.stubs(:status).returns(:failed)
    Import.stubs(:find).with(import.id.to_s).returns(import)

    get :show, id: import

    assert_select record_css_selector(import) do
      assert_select ".summary", /Import failed with 1 error/
      assert_select ".import_error" do
        assert_select ".row_number", "1"
        assert_select ".message", "Policy 'blah' does not exist"
      end
    end
  end

  def new_import
    @new_import ||= stub("new import", id: 1, to_param: "1", enqueue!: nil)
  end
end
