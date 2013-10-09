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

  view_test "show declares queued if queued" do
    import = stub_record(:import, creator: current_user, import_enqueued_at: Time.zone.now)
    import.stubs(:status).returns(:queued)
    Import.stubs(:find).with(import.id.to_s).returns(import)

    get :show, id: import

    assert_select record_css_selector(import) do
      assert_select ".summary", "Queued"
    end
  end

  view_test "shows errors if any" do
    import = create(:import, creator: current_user,
      import_enqueued_at: Time.zone.now,
      import_started_at: Time.zone.now,
      import_finished_at: Time.zone.now)
    import.import_errors.create(row_number: 2, message: "Policy 'blah' does not exist")

    get :error_list, id: import

    assert_select ".import_error" do
      assert_select ".row_number", "2"
      assert_select ".message", "Policy &#x27;blah&#x27; does not exist"
    end
  end

  test "can export annotated version of all rows" do
    import = create(:import, creator: current_user,
      original_filename: "consultations.csv",
      csv_data: consultation_csv_sample,
      import_enqueued_at: Time.zone.now,
      import_started_at: Time.zone.parse("2011-01-01 12:13:14"),
      import_finished_at: Time.zone.now)
    import.import_errors.create(row_number: 2, message: "Policy &#x27;blah&#x27; does not exist")

    get :annotated, id: import

    assert_equal "text/csv", response.headers["Content-Type"]
    assert_equal %{attachment; filename="consultations-all-2011-01-01-121314.csv"}, response.headers["Content-Disposition"]
    original_upload = CSV.parse(import.csv_data)
    parsed_response = CSV.parse(response.body)
    assert_equal original_upload.size, parsed_response.size
    assert_equal ["Errors"] + original_upload[0].map(&:downcase), parsed_response[0]
    assert_equal ["Policy &#x27;blah&#x27; does not exist"] + original_upload[1], parsed_response[1]
  end

  test 'asks the import to force_publish! if it is force_publishable?, and sends the user on their way with a message' do
    import = build(:import); import.stubs(:id).returns(1)
    import.stubs(:force_publishable?).returns true
    stub_controller_import_fetching(import)

    import.expects(:force_publish!)

    post :force_publish, id: import

    assert_redirected_to admin_imports_path
    assert_equal "Import #{import.id} queued for force publishing!", flash[:notice]
  end

  test 'does not ask the import to force_publish! if it is not force_publishable?, and sends the user on their way with a message' do
    import = build(:import); import.stubs(:id).returns(1)
    import.stubs(:force_publishable?).returns false
    stub_controller_import_fetching(import)

    import.expects(:force_publish!).never

    post :force_publish, id: import

    assert_redirected_to admin_imports_path
    assert_equal "Import #{import.id} is not force publishable!", flash[:alert]
  end

  test 'shows some detail about the most recent force publication attempt if it exists' do
    import = build(:import, created_at: Time.zone.now); import.stubs(:id).returns(1)
    import.stubs(:most_recent_force_publication_attempt).returns(
      ForcePublicationAttempt.new(enqueued_at: Time.zone.now, started_at: Time.zone.now, finished_at: Time.zone.now, total_documents: 10, successful_documents: 8)
    )
    stub_controller_import_fetching(import)

    get :force_publish_log, id: import

    assert_response :success
    assert_template :force_publish_log
  end

  test 'sends the user away with a message if the import has no force publication attempt' do
    import = build(:import); import.stubs(:id).returns(1)
    import.stubs(:most_recent_force_publication_attempt).returns nil
    stub_controller_import_fetching(import)

    get :force_publish_log, id: import

    assert_redirected_to admin_imports_path
    assert_equal "Import #{import.id} has not been force published yet!", flash[:notice]
  end

  def stub_controller_import_fetching(with_import)
    @controller.stubs(:find_import)
    @controller.instance_eval { @import = with_import }
  end

  def new_import
    @new_import ||= stub("new import", id: 1, to_param: "1", enqueue!: nil, valid?: true, document_sources: [], already_imported: [])
  end
end
