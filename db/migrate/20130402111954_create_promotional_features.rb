class CreatePromotionalFeatures < ActiveRecord::Migration
  def change
    create_table :promotional_features do |t|
      t.references :organisation
      t.string     :title

      t.timestamps
    end

    add_index :promotional_features, :organisation_id
  end
end
