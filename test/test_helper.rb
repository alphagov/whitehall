$:.unshift(File.dirname(__FILE__))
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

if ENV["TEST_COVERAGE"]
  Bundler.require(:test_coverage)
  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

require 'rails/test_help'
require 'mocha/setup'
require 'slimmer/test'
require 'factories'
require 'webmock/test_unit'
require 'whitehall/not_quite_as_fake_search'

Dir[Rails.root.join('test/support/*.rb')].each { |f| require f }

Mocha::Configuration.prevent(:stubbing_non_existent_method)

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include ModelHelpers
  include ModelStubbingHelpers
  include HtmlAssertions
  include I18nHelpers
  include DelayedJobTestHelpers
  extend GovspeakValidationTestHelper

  setup do
    Timecop.freeze(2011, 11, 11, 11, 11, 11)
    Whitehall.search_backend = Whitehall::DocumentFilter::FakeSearch
    ImageSizeChecker.any_instance.stubs(:size_is?).returns true
  end

  teardown do
    Timecop.return
  end

  def acting_as(actor, &block)
    Edition::AuditTrail.acting_as(actor, &block)
  end

  def assert_same_elements(array1, array2)
    assert_equal array1.to_set, array2.to_set, "Different elements in #{array1.inspect} and #{array2}.inspect"
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

  def with_mainstream_content_api(content_api, &block)
    with_service(:mainstream_content_api, content_api, &block)
  end

  def routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new
  end

  class << self
    def disable_database_queries
      self.use_transactional_fixtures = false
      setup do
        ActiveRecord::Base.connection.expects(:select).never
      end
    end

    def class_for(document_type)
      document_type.to_s.classify.constantize
    end

    def class_from_test_name
      name.sub(/Test$/, '').constantize
    end

    def factory_name_from_test
      name.sub(/Test$/, '').underscore.to_sym
    end

    def with_not_quite_as_fake_search
      setup do
        Whitehall::NotQuiteAsFakeSearch.stop_faking_it_quite_so_much!
      end
    end
  end

  def class_from_test_name
    self.class.class_from_test_name
  end

  def factory_name_from_test
    self.class.factory_name_from_test
  end
end

class ActionController::TestCase
  include HtmlAssertions
  include AdminControllerTestHelpers
  include AdminEditionControllerTestHelpers
  include AdminEditionAttachableControllerTestHelpers
  include AdminEditionControllerScheduledPublishingTestHelpers
  include AdminEditionWorldLocationsBehaviour
  include DocumentControllerTestHelpers
  include ControllerTestHelpers
  include ResourceTestHelpers
  include AtomTestHelpers
  include CacheControlTestHelpers
  include ViewRendering

  attr_reader :current_user

  setup do
    request.env['warden'] = stub(authenticate!: false, authenticated?: false, user: nil)
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
    define_method :default_url_options do
      {host: "example.com"}
    end
  end
end

class ActionView::TestCase
  def assert_select_in_html(text, *args, &block)
    assert_select HTML::Document.new(text).root, *args, &block
  end
end

class PresenterTestCase < ActionView::TestCase
  disable_database_queries

  setup do
    @view_context = @controller.view_context
  end

  def stubs_helper_method(*args)
    @view_context.stubs(*args)
  end

  def assert_select_from(text, *args, &block)
    assert_select HTML::Document.new(text).root, *args, &block
  end
end
