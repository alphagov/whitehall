# Use this helper to write performance tests that benchmark requests in a more
# "production"-like context. This helps to accurately measure the actual
# improvement of performance optimisations.
#
# Performance tests run with this helper will run the tests in the "benchmark"
# environment, which differs from the "test" environment in the following ways:
#
#   * It behaves more like "production" (i.e. caching is enabled)
#   * It runs against the "development" database (i.e. a full data dump)
#   * The database is *not* rebuilt before the tests are run
#
# By enabling caching and running against the "development" database, we get a
# more accurate measure of how requests will actually perform in production
# when a full database is present.
#
# A rake task exists that will run these performance tests:
#
#  rake test:alt_benchmarks
#
$:.unshift(File.dirname(__FILE__))
ENV["RAILS_ENV"] = "benchmark"
require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'
require 'rails/performance_test_help'

class ActionDispatch::PerformanceTest
  include Warden::Test::Helpers

  self.profile_options = { :runs => 5, :metrics => [:wall_time],
                           :output => 'tmp/performance', :formats => [:flat] }

private

  def login_as(user)
    GDS::SSO.test_user = user
    Edition::AuditTrail.whodunnit = user
    super(user) # warden
  end

  def logout
    GDS::SSO.test_user = nil
    Edition::AuditTrail.whodunnit = nil
    super #warden
    Warden.test_reset!
  end

  def editor
    @editor ||= User.first
  end
end
