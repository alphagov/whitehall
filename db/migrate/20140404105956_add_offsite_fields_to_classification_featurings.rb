class AddOffsiteFieldsToClassificationFeaturings < ActiveRecord::Migration
  def change
    add_column :classification_featurings, :offsite_title, :string
    add_column :classification_featurings, :offsite_summary, :text
    add_column :classification_featurings, :offsite_url, :string
  end
end
