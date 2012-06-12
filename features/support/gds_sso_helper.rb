require "warden/test/helpers"

module GdsSsoHelper
  def login_as(user)
    GDS::SSO.test_user = user
    PaperTrail.whodunnit = user
  end

  def log_out
    login_as nil
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
end