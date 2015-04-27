class CreateFeatureFlags < ActiveRecord::Migration
  def change
    create_table :feature_flags do |t|
      t.string :key, unique: true
      t.boolean :enabled, default: false
    end

    FeatureFlag.create(key: 'future_policies')
  end
end
