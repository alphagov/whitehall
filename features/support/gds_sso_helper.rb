require "warden/test/helpers"

module GdsSsoHelper
  include Warden::Test::Helpers

  def login_as(user)
    GDS::SSO.test_user = user
    AuditTrail.whodunnit = user
    super(user) # warden
  end

  def log_out
    GDS::SSO.test_user = nil
    AuditTrail.whodunnit = nil
    logout # warden
  end

  def as_user(user)
    original_user = GDS::SSO.test_user
    login_as(user)
    yield
    login_as(original_user)
  end
end

World(GdsSsoHelper)

After do
  log_out
  Warden.test_reset!
end
