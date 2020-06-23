require "test_helper"

class DocumentListExportRequestControllerTest < ActionController::TestCase
  setup do
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

  test "responds successfully if there is a valid file" do
    login_as :gds_editor

    document_type_slug = "asylum-support-decisions"
    export_id = "1234-5678"
    filename = "document_list_#{document_type_slug}_#{export_id}.csv"

    @directory.files.create(key: filename, body: "hello world") # rubocop:disable Rails/SaveBang

    get :show, params: { document_type_slug: document_type_slug, export_id: export_id }
    assert_equal 200, response.status
    assert_equal "hello world", response.body
  end

  test "returns an error if there is no request" do
    login_as :gds_editor

    get :show, params: { document_type_slug: "asylum-support-decisions", export_id: "aaaa-bbbb" }
    assert_equal 404, response.status
  end

  test "returns an error if not logged in" do
    document_type_slug = "asylum-support-decisions"
    export_id = "1234-5678"
    filename = "document_list_#{document_type_slug}_#{export_id}.csv"

    @directory.files.create(key: filename, body: "hello world") # rubocop:disable Rails/SaveBang

    get :show, params: { document_type_slug: document_type_slug, export_id: export_id }
    assert_equal 401, response.status
  end
end
