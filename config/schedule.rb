$: << '.'
require File.dirname(__FILE__) + "/initializers/scheduled_publishing"

every SCHEDULED_PUBLISHING_PRECISION_IN_MINUTES.minutes, roles: [:backend] do
  rake "publishing:due:publish"
end
