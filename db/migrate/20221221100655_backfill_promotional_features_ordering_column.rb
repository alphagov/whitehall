class BackfillPromotionalFeaturesOrderingColumn < ActiveRecord::Migration[7.0]
  def change
     Organisation.joins(:promotional_features).each do |organisation|
       organisation.promotional_features.each_with_index do |promotional_feature, index|
         promotional_feature.update!(ordering: index + 1)
       end
     end
  end
end
