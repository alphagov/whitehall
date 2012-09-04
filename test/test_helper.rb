$:.unshift(File.dirname(__FILE__))
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

if ENV["TEST_COVERAGE"]
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.start 'rails'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

require 'rails/test_help'
require 'mocha'
require 'slimmer/test'
require 'factories'
require 'webmock/test_unit'
Dir[Rails.root.join('test/support/*.rb')].each { |f| require f }

Mocha::Configuration.prevent(:stubbing_non_existent_method)

class ActiveSupport::TestCase
  include Factory::Syntax::Methods
  include ModelStubbingHelpers
  include HtmlAssertions

  setup do
    Timecop.freeze(2011, 11, 11, 11, 11, 11)
  end

  teardown do
    Timecop.return
  end

  def acting_as(user)
    original_user = PaperTrail.whodunnit
    PaperTrail.whodunnit = user
    yield
  ensure
    PaperTrail.whodunnit = original_user
  end

  def assert_same_elements(array1, array2)
    assert_equal array1.sort, array2.sort, "Different elements in #{array1.inspect} and #{array2}.inspect"
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

  class << self
    def disable_database_queries
      self.use_transactional_fixtures = false
      setup do
        ActiveRecord::Base.connection.expects(:select).never
      end
    end

    def edition_class_for(document_type)
      document_type.to_s.classify.constantize
    end

    def edition_class_from_test_name
      name.sub(/Test$/, '').constantize
    end
  end

  def edition_class_from_test_name
    self.class.edition_class_from_test_name
  end
end

class ActionController::TestCase
  include HtmlAssertions
  include AdminEditionControllerTestHelpers
  include AdminEditionCountriesBehaviour
  include DocumentControllerTestHelpers
  include ControllerTestHelpers
  include ResourceTestHelpers
  include AtomTestHelpers

  attr_reader :current_user

  setup do
    request.env['warden'] = stub(authenticate!: false, authenticated?: false, user: nil)
  end

  def login_as(role_or_user)
    @current_user = role_or_user.is_a?(Symbol) ? create(role_or_user) : role_or_user
    request.env['warden'] = stub(authenticate!: true, authenticated?: true, user: @current_user)
    @previous_papertrail_whodunnit ||= PaperTrail.whodunnit
    PaperTrail.whodunnit = @current_user
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
    Draper::ViewContext.current = @controller.view_context
  end

  def assert_select_from(text, *args, &block)
    assert_select HTML::Document.new(text).root, *args, &block
  end
end

class EditionTestCase < ActiveSupport::TestCase
  include DocumentBehaviour
end