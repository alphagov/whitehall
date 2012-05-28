require "warden/test/helpers"

module GdsSsoHelper
  def login_as(user)
    GDS::SSO.test_user = user
    PaperTrail.whodunnit = user
  end

  def log_out
    login_as nil
  end
end

World(GdsSsoHelper)

After do
  log_out
end