class AddAnalyticsIdentifierToEditions < ActiveRecord::Migration[7.1]
  def change
    add_column :editions, :analytics_identifier, :string
  end
end
