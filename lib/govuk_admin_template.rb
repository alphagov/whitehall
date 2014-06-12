# Placeholder module to hold the environment config
# until this is transitioned to actually use the gem.

module GovukAdminTemplate
  mattr_accessor :environment_style

  mattr_accessor :environment_label
  def self.environment_label
    @@environment_label || self.environment_style.try(:titleize)
  end
end
