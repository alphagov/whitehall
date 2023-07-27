require "test_helper"

class DocumentListExportWorkerTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @worker = DocumentListExportWorker.new

    setup_fog_mock
  end

  teardown do
    Fog::Mock.reset
  end

  test "instantiates an EditionFilter with passed options converted to symbols" do
    Admin::EditionFilter.expects(:new).with(Edition, @user, { state: "draft", include_unpublishing: true })
    @worker.stubs(generate_csv: "")
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
    MailNotifications.expects(:document_list).with(regexp_matches(%r{^https://whitehall-admin\.test\.gov\.uk/export/documents/[a-f0-9-]{36}$}), @user.email, title).returns(stub(deliver_now: nil))
    @worker.perform({ "state" => "draft" }, @user.id)
  end

  test "does not raise an error if an email cannot be sent via notify" do
    raises_exception = lambda { |_url, _address, _title|
      response = Minitest::Mock.new
      ENV["SENTRY_CURRENT_ENV"] = "integration-blue-aws"
      response.expect :code, 400
      response.expect :body, "Can't send to this recipient using a team-only API key"
      raise Notifications::Client::BadRequestError, response
    }

    MailNotifications.stub(:document_list, raises_exception) do
      ActionMailer::Base.deliveries.clear

      csv = "this|is|my|csv"
      title = "Everyone's editions"
      @worker.stubs(:create_filter).returns(stub(page_title: title))
      @worker.stubs(generate_csv: csv)
      assert_nothing_raised do
        @worker.perform({ "state" => "draft" }, @user.id)
      end
    end
  end

  test "raises an error if an email cannot be sent via notify in production" do
    raises_exception = lambda { |_url, _address, _title|
      response = Minitest::Mock.new
      ENV["SENTRY_CURRENT_ENV"] = "production"
      response.expect :code, 400
      response.expect :body, "Can't send to this recipient using a team-only API key"
      raise Notifications::Client::BadRequestError, response
    }

    MailNotifications.stub(:document_list, raises_exception) do
      ActionMailer::Base.deliveries.clear

      csv = "this|is|my|csv"
      title = "Everyone's editions"
      @worker.stubs(:create_filter).returns(stub(page_title: title))
      @worker.stubs(generate_csv: csv)

      assert_raises Notifications::Client::BadRequestError do
        @worker.perform({ "state" => "draft" }, @user.id)
      end
    end
  end
end
