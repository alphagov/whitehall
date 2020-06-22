require "test_helper"

class DocumentListExportWorkerTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @worker = DocumentListExportWorker.new

    Fog.mock!
    ENV["AWS_REGION"] = "eu-west-1"
    ENV["AWS_ACCESS_KEY_ID"] = "test"
    ENV["AWS_SECRET_ACCESS_KEY"] = "test"
    ENV["AWS_S3_BUCKET_NAME"] = "test-bucket"

    # Create an S3 bucket so the code being tested can find it
    connection = Fog::Storage.new(
      provider: "AWS",
      region: ENV["AWS_REGION"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )
    @directory = connection.directories.get(ENV["AWS_S3_BUCKET_NAME"]) || connection.directories.create(key: ENV["AWS_S3_BUCKET_NAME"]) # rubocop:disable Rails/SaveBang
  end

  teardown do
    Fog::Mock.reset
  end

  test "instantiates an EditionFilter with passed options converted to symbols" do
    Admin::EditionFilter.expects(:new).with(Edition, @user, state: "draft", include_unpublishing: true, include_locked_documents: false)
    @worker.stubs(:generate_csv)
    @worker.stubs(:send_mail)
    @worker.perform({ "state" => "draft" }, @user.id)
  end

  test "generate_csv calls presenter once for each edition" do
    filter = mock
    filter.expects(:each_edition_for_csv).multiple_yields(1, 2, 3)
    @worker.stubs(:create_filter).returns(filter)
    @worker.stubs(:send_mail)
    DocumentListExportPresenter.expects(:new).returns(stub(row: [])).times(3)
    @worker.perform({ "state" => "draft" }, @user.id)
  end

  test "uploads csv to s3" do
    csv = "this|is|my|csv"
    title = "Everyone's editions"
    @worker.stubs(:create_filter).returns(stub(page_title: title))
    @worker.stubs(generate_csv: csv)
    @worker.stubs(:send_mail)

    @worker.perform({ "state" => "draft" }, @user.id)

    assert_equal 1, @directory.files.length
    file = @directory.files[0]
    assert_not_nil file
    assert_match %r{^document_list_documents_[a-f0-9-]{36}\.csv$}, file.key
    assert_equal "this|is|my|csv", file.body
  end

  test "sends mail with CSV link to user" do
    csv = "this|is|my|csv"
    title = "Everyone's editions"
    @worker.stubs(:create_filter).returns(stub(page_title: title))
    @worker.stubs(generate_csv: csv)
    Notifications.expects(:document_list).with(regexp_matches(%r{^https://whitehall\.test\.gov\.uk/export/documents/[a-f0-9-]{36}$}), @user.email, title).returns(stub(deliver_now: nil))
    @worker.perform({ "state" => "draft" }, @user.id)
  end
end
