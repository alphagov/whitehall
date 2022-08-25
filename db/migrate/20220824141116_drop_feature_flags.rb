class DropFeatureFlags < ActiveRecord::Migration[7.0]
  def up
    drop_table :feature_flags
  end
end
