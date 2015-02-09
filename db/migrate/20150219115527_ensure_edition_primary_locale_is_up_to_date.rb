class EnsureEditionPrimaryLocaleIsUpToDate < ActiveRecord::Migration
  def up
    execute "UPDATE editions SET primary_locale = locale WHERE primary_locale != locale"
  end
end
