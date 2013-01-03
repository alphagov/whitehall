require 'test_helper'
require 'support/consultation_csv_sample_helpers'

class Admin::ImportsControllerTest < ActionController::TestCase
  include ConsultationCsvSampleHelpers

  def organisation_id
    "1"
  end

  setup do
    login_as :importer
  end

  should_be_an_admin_controller

  test "import permission required to access" do
    login_as :departmental_editor
    get :new
    assert_response 403
  end

  test "new shows an interface to start a new import" do
    get :new
  end

  test "be able to upload a tagged CSV file" do
    csv_file = fixture_file_upload("dft_publication_import_with_json_test.csv")
    Import.expects(:create_from_file).with(anything, csv_file, "consultation", organisation_id).returns(new_import)
    post :create, import: {file: csv_file, data_type: "consultation", organisation_id: organisation_id}
  end

  test "record the person who uploaded a CSV file" do
    csv_file = fixture_file_upload("dft_publication_import_with_json_test.csv")
    Import.expects(:create_from_file).with(current_user, anything, anything, anything).returns(new_import)
    post :create, import: {file: csv_file}
  end

  test "should run an existing import when the run button is clicked" do
    import = stub_record(:import, creator: current_user)
    import.stubs(:status).returns(:new)
    Import.stubs(:find).with(import.id.to_s).returns(import)

    import.expects(:enqueue!)
    post :run, id: import
  end

  test "redirects to show on successful upload" do
    Import.stubs(:create_from_file).returns(new_import)
    post :create, import: {file: fixture_file_upload("dft_publication_import_with_json_test.csv")}
    assert_redirected_to admin_import_path(new_import)
  end

  test "show declares queued if queued" do
    import = stub_record(:import, creator: current_user, import_enqueued_at: Time.zone.now)
    import.stubs(:status).returns(:queued)
    Import.stubs(:find).with(import.id.to_s).returns(import)

    get :show, id: import

    assert_select record_css_selector(import) do
      assert_select ".summary", "Queued"
    end
  end

  test "show shows declares success on success" do
    import = stub_record(:import, creator: current_user, document_sources: [], already_imported: [],
      import_enqueued_at: Time.zone.now, import_started_at: Time.zone.now, import_finished_at: Time.zone.now)
    import.stubs(:status).returns(:success)
    Import.stubs(:find).with(import.id.to_s).returns(import)

    get :show, id: import

    assert_select record_css_selector(import) do
      assert_select ".summary", /Imported successfully/
    end
  end

  test "show shows errors if any" do
    import = create(:import, creator: current_user,
      import_enqueued_at: Time.zone.now,
      import_started_at: Time.zone.now,
      import_finished_at: Time.zone.now)
    import.import_errors.create(row_number: 2, message: "Policy 'blah' does not exist")

    get :show, id: import

    assert_select record_css_selector(import) do
      assert_select ".summary", /Import failed with 1 error/
      assert_select ".import_error" do
        assert_select ".row_number", "2"
        assert_select ".message", "Policy &#x27;blah&#x27; does not exist"
      end
    end
  end

  test "can export annotated version of file with errors" do
    import = create(:import, creator: current_user,
      original_filename: "consultations.csv",
      csv_data: consultation_csv_sample,
      import_enqueued_at: Time.zone.now,
      import_started_at: Time.zone.parse("2011-01-01 12:13:14"),
      import_finished_at: Time.zone.now)
    import.import_errors.create(row_number: 2, message: "Policy &#x27;blah&#x27; does not exist")

    get :annotated, id: import

    assert_equal "text/csv", response.headers["Content-Type"]
    assert_equal %{attachment; filename="consultations-errors-2011-01-01-121314.csv"}, response.headers["Content-Disposition"]
    original_upload = CSV.parse(import.csv_data)
    parsed_response = CSV.parse(response.body)
    assert_equal original_upload.size, parsed_response.size
    assert_equal ["Errors"] + original_upload[0].map(&:downcase), parsed_response[0]
    assert_equal ["Policy &#x27;blah&#x27; does not exist"] + original_upload[1], parsed_response[1]
  end

  def new_import
    @new_import ||= stub("new import", id: 1, to_param: "1", enqueue!: nil, valid?: true, document_sources: [], already_imported: [])
  end
end
