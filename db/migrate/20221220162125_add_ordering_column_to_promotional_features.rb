class AddOrderingColumnToPromotionalFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :promotional_features, :ordering, :integer
  end
end
