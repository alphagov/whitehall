class CollapseFeaturingsIntoDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :featured, :boolean, default: false
    add_column :documents, :carrierwave_featuring_image, :string

    update(%{
      UPDATE documents, featurings
        SET documents.featured = 1,
            documents.carrierwave_featuring_image = featurings.carrierwave_image
        WHERE documents.featuring_id = featurings.id
    })

    remove_column :documents, :featuring_id
    drop_table :featurings
  end
end
