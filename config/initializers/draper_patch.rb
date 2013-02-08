# Include patch from https://github.com/drapergem/draper/commit/027a2cd4b6e3292a755ed301e86bc75039150992
# This fix was made in draper 0.18.0, but that depends on activesupport ~> 3.2.x,
# and our version of Rails is locked at 3.1.x
require "draper/base"
class Draper::Base
  def localize(object, options = {})
    self.class.helpers.localize(object, options)
  end
  alias_method :l, :localize
end
