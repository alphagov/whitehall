class RemoveFeaturingImagesColumn < ActiveRecord::Migration
  def change
    remove_column :documents, :carrierwave_featuring_image
  end
end
