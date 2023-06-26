$LOAD_PATH.unshift(File.dirname(__FILE__))
ENV["RAILS_ENV"] = "test"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails"
  SimpleCov.command_name "Unit Tests"
  SimpleCov.merge_timeout 3600
end

require File.expand_path("../config/environment", __dir__)

require "maxitest/autorun"
require "rails/test_help"
require "mocha/minitest"
require "slimmer/test"
require "factories"
require "webmock/minitest"
require "whitehall/search_index"
require "sidekiq/testing"
require "govuk_schemas/assert_matchers"

if ENV["USE_I18N_COVERAGE"]
  require "i18n/coverage"
  require "i18n/coverage/printers/file_printer"
  I18n::Coverage.config.printer = I18n::Coverage::Printers::FilePrinter
  I18n::Coverage.start
end

Dir[Rails.root.join("test/support/*.rb")].sort.each { |f| require f }

Whitehall::Application.load_tasks if Rake::Task.tasks.empty?

Mocha.configure do |c|
  c.stubbing_non_existent_method = :prevent
end

class ActiveSupport::TestCase
  include AssetManagerTestHelpers
  include FactoryBot::Syntax::Methods
  include ModelHelpers
  include ModelStubbingHelpers
  include HtmlAssertions
  include I18nHelpers
  include PublishingApiTestHelpers
  include GovukSchemas::AssertMatchers
  include UrlHelpers
  extend GovspeakValidationTestHelper

  parallelize(workers: :number_of_processors)

  # Fix the merging of coverage reports from parallel processes when using
  # Rails 6 parallelization rather than parallel_tests
  # from https://github.com/simplecov-ruby/simplecov/issues/718#issuecomment-538201587
  if ENV["COVERAGE"]
    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end
  end

  setup do
    Timecop.freeze(2011, 11, 11, 11, 11, 11)
    Sidekiq::Worker.clear_all
    fake_whodunnit = FactoryBot.build(:user)
    fake_whodunnit.stubs(:id).returns(1000)
    fake_whodunnit.stubs(:persisted?).returns(true)
    AuditTrail.whodunnit = fake_whodunnit
    stub_any_publishing_api_call
    stub_publishing_api_publish_intent
    Services.stubs(:asset_manager).returns(stub_everything("asset-manager"))
  end

  teardown do
    AuditTrail.whodunnit = nil
    Timecop.return
    Sidekiq::Worker.clear_all
  end

  def acting_as(actor, &block)
    AuditTrail.acting_as(actor, &block)
  end

  def assert_same_elements(array1, array2)
    assert_equal array1.to_set, array2.to_set, "Different elements in #{array1.inspect} and #{array2}.inspect"
  end

  def assert_hash_includes(hash, should_exist)
    assert should_exist.to_a.all? { |e| hash.to_a.include?(e) }, "#{hash} doesn't include #{should_exist}"
  end

  def assert_all_requested(array)
    array.each { |request| assert_requested request }
  end

  def count_queries
    count = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*_args|
      count += 1
    end
    yield
    count
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  def with_service(service_name, service)
    original_service = Whitehall.send(service_name)
    Whitehall.send(:"#{service_name}=", service)
    yield
  ensure
    Whitehall.send(:"#{service_name}=", original_service)
  end

  def routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new
  end

  def self.disable_database_queries
    setup do
      ActiveRecord::Base
        .connection
        .stubs(:select)
        .raises("Database queries are disabled")
    end
    teardown do
      ActiveRecord::Base.connection.unstub(:select)
    end
  end

  def self.class_for(document_type)
    document_type.to_s.classify.constantize
  end

  def self.class_from_test_name
    name.sub(/Test$/, "").constantize
  end

  def self.factory_name_from_test
    name.sub(/Test$/, "").underscore.to_sym
  end

  def class_from_test_name
    self.class.class_from_test_name
  end

  def factory_name_from_test
    self.class.factory_name_from_test
  end

  def file_fixture(filename)
    File.new(Rails.root.join("test/fixtures", filename))
  end

  def upload_fixture(filename, mime_type = nil)
    Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures", filename), mime_type)
  end

  def assert_file_content_identical(file1, file2)
    FileUtils.compare_file(file1.path, file2.path)
  end

  def publish(edition)
    publisher = EditionPublisher.new(edition)
    unless publisher.perform!
      raise "Could not publish edition: #{publisher.failure_reason}"
    end
  end

  def force_publish(edition)
    publisher = EditionForcePublisher.new(edition)
    unless publisher.perform!
      raise "Could not force publish edition: #{publisher.failure_reason}"
    end
  end

  def fixture_path
    Pathname.new(Rails.root.join("test/fixtures"))
  end

  def setup_fog_mock
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
    @directory = connection.directories.create(key: ENV["AWS_S3_BUCKET_NAME"]) # rubocop:disable Rails/SaveBang
  end
end

class ActionController::TestCase
  include HtmlAssertions
  include AdminControllerTestHelpers
  include AdminEditionControllerTestHelpers
  include AdminEditionControllerScheduledPublishingTestHelpers
  include AdminEditionWorldLocationsBehaviour
  include DocumentControllerTestHelpers
  include ControllerTestHelpers
  include ResourceTestHelpers
  include AtomTestHelpers
  include CacheControlTestHelpers
  include ViewRendering

  include Admin::EditionRoutesHelper

  attr_reader :current_user

  setup do
    request.env["warden"] = stub(authenticate!: false, authenticated?: false, user: nil)

    # In controller tests, stub out all calls to the content store. This
    # implies that by default we don't care about responses from this endpoint,
    # which is currently only used to render specialist sector links in the
    # header.
    stub_request(:get, %r{.*content-store.*/content/.*}).to_return(status: 404)
    stub_publishing_api_has_linkables([], document_type: "topic")

    stub_request(:get, %r{\A#{Plek.find('publishing-api')}/v2/links/}).to_return(body: { links: {} }.to_json)
  end

  def login_as(role_or_user, organisation = nil)
    @current_user = role_or_user.is_a?(Symbol) ? create(role_or_user, organisation:) : role_or_user
    request.env["warden"] = stub(authenticate!: true, authenticated?: true, user: @current_user)
    AuditTrail.whodunnit = @current_user
    @current_user
  end

  def login_as_admin
    login_as(create(:user, name: "user-name", email: "user@example.com"))
  end

  def login_as_preview_design_system_user(role, organisation = nil)
    login_as(create(role, :with_preview_design_system, name: "user-name", email: "user@example.com", organisation:))
  end

  def login_as_use_non_legacy_endpoints_user(role, organisation = nil)
    login_as(create(role, :with_use_non_legacy_endpoints, name: "user-name", email: "user@example.com", organisation:))
  end

  def assert_login_required
    assert_redirected_to login_path
  end

  def json_response
    ActiveSupport::JSON.decode(response.body)
  end
end

class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def login_as(user)
    GDS::SSO.test_user = user
    super
  end

  def login_as_admin
    login_as(create(:user, name: "user-name", email: "user@example.com"))
  end

  def logout
    GDS::SSO.test_user = nil
    super
  end

  teardown do
    GDS::SSO.test_user = nil
  end
end

class ActionMailer::TestCase
  include UrlHelpers
end

class ActionView::TestCase
  def setup_view_context
    @view_context = @controller.view_context
  end
end

class PresenterTestCase < ActionView::TestCase
  disable_database_queries

  setup :setup_view_context

  def stubs_helper_method(*args)
    @view_context.stubs(*args)
  end
end
