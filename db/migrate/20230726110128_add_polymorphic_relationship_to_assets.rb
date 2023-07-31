class AddPolymorphicRelationshipToAssets < ActiveRecord::Migration[7.0]
  def change
    remove_reference :assets, :attachment_data, index: true, if_exists: true
    add_reference :assets, :assetable, polymorphic: true
  end
end
