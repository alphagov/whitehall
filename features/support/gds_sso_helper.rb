require "warden/test/helpers"

module GdsSsoHelper
  def login_as(user)
    GDS::SSO.test_user = user
    PaperTrail.whodunnit = user
  end
end

World(GdsSsoHelper)