ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'slimmer/test'
require 'factories'
Dir[Rails.root.join('test/support/*.rb')].each { |f| require f }

Mocha::Configuration.prevent(:stubbing_non_existent_method)

class ActiveSupport::TestCase
  include Factory::Syntax::Methods

  setup do
    Timecop.freeze(2011, 11, 11, 11, 11, 11)
  end

  teardown do
    Timecop.return
  end

  def assert_same_elements(array1, array2)
    assert_equal array1.sort, array2.sort, "Different elements in #{array1.inspect} and #{array2}.inspect"
  end
end

class ActionController::TestCase
  include CssSelectors
  include AdminDocumentControllerTestHelpers
  include DocumentControllerTestHelpers
  include ControllerTestHelpers
  include ResourceTestHelpers

  attr_reader :current_user

  def login_as(role_or_user)
    @current_user = role_or_user.is_a?(Symbol) ? create(role_or_user) : role_or_user
    request.env['warden'] = stub(authenticate!: true, authenticated?: true, user: @current_user)
    @current_user
  end

  def login_as_admin
    login_as(create(:user, name: "user-name", email: "user@example.com"))
  end

  def assert_login_required
    assert_redirected_to login_path
  end

  def assert_select_object(object, *args, &block)
    assert_select record_css_selector(object), *args, &block
  end

  def refute_select(selector, options = {})
    assert_select selector, options.merge(count: 0)
  end

  def refute_select_object(object)
    assert_select_object object, count: 0
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