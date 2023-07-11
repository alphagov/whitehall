class AddTaxonomyTopicEmailOverrideToEditions < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :taxonomy_topic_email_override, :string
  end
end
