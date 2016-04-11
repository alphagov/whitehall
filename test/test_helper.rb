$:.unshift(File.dirname(__FILE__))
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

if ENV["TEST_COVERAGE"]
  Bundler.require(:test_coverage)
  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

require 'maxitest/autorun'
require 'rails/test_help'
require 'mocha/setup'
require 'slimmer/test'
require 'factories'
require 'webmock/minitest'
require 'whitehall/not_quite_as_fake_search'
require 'whitehall/search_index'
require 'sidekiq/testing/inline'
require 'govuk-content-schema-test-helpers/test_unit'

Dir[Rails.root.join('test/support/*.rb')].each { |f| require f }

Mocha::Configuration.prevent(:stubbing_non_existent_method)

GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = 'publisher_v2'
  config.project_root = Rails.root
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include ModelHelpers
  include ModelStubbingHelpers
  include HtmlAssertions
  include I18nHelpers
  include PanopticonTestHelpers
  include PublishingApiTestHelpers
  include PolicyTaggingHelpers
  include GovukContentSchemaTestHelpers::TestUnit
  extend GovspeakValidationTestHelper

  setup do
    Timecop.freeze(2011, 11, 11, 11, 11, 11)
    Whitehall.search_backend = Whitehall::DocumentFilter::FakeSearch
    VirusScanHelpers.erase_test_files
    Sidekiq::Worker.clear_all
    fake_whodunnit = FactoryGirl.build(:user)
    fake_whodunnit.stubs(:id).returns(1000)
    fake_whodunnit.stubs(:persisted?).returns(true)
    Edition::AuditTrail.whodunnit = fake_whodunnit
    stub_any_publishing_api_call
    stub_publishing_api_policies
  end

  teardown do
    Edition::AuditTrail.whodunnit = nil
    Timecop.return
    DatabaseCleaner.clean_with(:truncation, pre_count: true, reset_ids: false)
  end

  def acting_as(actor, &block)
    Edition::AuditTrail.acting_as(actor, &block)
  end

  def assert_same_elements(array1, array2)
    assert_equal array1.to_set, array2.to_set, "Different elements in #{array1.inspect} and #{array2}.inspect"
  end

  def assert_all_requested(array)
    array.each { |request| assert_requested request }
  end

  def count_queries
    count = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
      count = count + 1
    end
    yield
    count
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  def with_service(service_name, service, &block)
    original_service = Whitehall.send(service_name)
    Whitehall.send(:"#{service_name}=", service)
    yield
  ensure
    Whitehall.send(:"#{service_name}=", original_service)
  end

  def with_content_api(content_api, &block)
    with_service(:content_api, content_api, &block)
  end

  def routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new
  end

  def self.disable_database_queries
    setup do
      ActiveRecord::Base.connection.expects(:select).never
    end
    teardown do
      ActiveRecord::Base.connection.unstub(:select)
    end
  end

  def self.class_for(document_type)
    document_type.to_s.classify.constantize
  end

  def self.class_from_test_name
    name.sub(/Test$/, '').constantize
  end

  def self.factory_name_from_test
    name.sub(/Test$/, '').underscore.to_sym
  end

  def self.with_not_quite_as_fake_search
    setup do
      Whitehall::NotQuiteAsFakeSearch.stop_faking_it_quite_so_much!
    end

    teardown do
      Whitehall::NotQuiteAsFakeSearch.start_faking_it_again!
    end
  end

  def class_from_test_name
    self.class.class_from_test_name
  end

  def factory_name_from_test
    self.class.factory_name_from_test
  end

  def file_fixture(filename)
    File.new(Rails.root.join('test/fixtures', filename))
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

  include PublicDocumentRoutesHelper
  include Admin::EditionRoutesHelper

  attr_reader :current_user

  setup do
    request.env['warden'] = stub(authenticate!: false, authenticated?: false, user: nil)

    # In controller tests, assume by default that the resource being rendered
    # does not have any topic tags.
    SpecialistTagFinder.any_instance.stubs(:grandparent_topic).returns(nil)
    SpecialistTagFinder.any_instance.stubs(:topics).returns([])
  end

  def login_as(role_or_user)
    @current_user = role_or_user.is_a?(Symbol) ? create(role_or_user) : role_or_user
    request.env['warden'] = stub(authenticate!: true, authenticated?: true, user: @current_user)
    @previous_papertrail_whodunnit ||= Edition::AuditTrail.whodunnit
    Edition::AuditTrail.whodunnit = @current_user
    @current_user
  end

  def login_as_admin
    login_as(create(:user, name: "user-name", email: "user@example.com"))
  end

  def assert_login_required
    assert_redirected_to login_path
  end

  def json_response
    ActiveSupport::JSON.decode(response.body)
  end
end

class ActionDispatch::IntegrationTest
  def login_as(user)
    GDS::SSO.test_user = user
  end

  def login_as_admin
    login_as(create(:user, name: "user-name", email: "user@example.com"))
  end

  teardown do
    GDS::SSO.test_user = nil
  end
end

class ActionMailer::TestCase
  def self.enable_url_helpers
    # See http://jakegoulding.com/blog/2011/02/26/using-named-routes-in-actionmailer-tests-with-rails-3/
    include Rails.application.routes.url_helpers
    Rails.application.routes.default_url_options[:host] = "example.com"
    def default_url_options
      Rails.application.routes.default_url_options
    end
  end
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
