# This file is overwritten on deploy

if Rails.env.development?
  GovukAdminTemplate.environment_style = "development"
end
