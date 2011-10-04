ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'factories'
Dir[Rails.root.join('test/support/*.rb')].each { |f| require f }

class ActiveSupport::TestCase
  include Factory::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include CssSelectors
  def login_as(name, attributes={})
    user = User.find_or_create_by_name(name, attributes)
    session[:user_id] = user.id
    user
  end

  def assert_login_required
    assert_redirected_to login_path
  end

  def assert_select_object(object, &block)
    assert_select record_css_selector(object), &block
  end
end

class ActionMailer::TestCase
  def self.enable_url_helpers
    # See http://jakegoulding.com/blog/2011/02/26/using-named-routes-in-actionmailer-tests-with-rails-3/
    include Rails.application.routes.url_helpers
    define_method :default_url_options do
      Rails.application.config.action_mailer.default_url_options
    end
  end
end