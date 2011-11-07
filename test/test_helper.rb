ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
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
  include DocumentControllerTestHelpers

  def login_as(role_or_user)
    user = role_or_user.is_a?(Symbol) ? create(role_or_user) : role_or_user
    session[:user_id] = user.id
    user
  end

  def assert_login_required
    assert_redirected_to login_path
  end

  def assert_select_object(object, *args, &block)
    assert_select record_css_selector(object), *args, &block
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