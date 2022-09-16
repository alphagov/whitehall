module PromotionalFeaturesHelper
  def create_feature_item_for(organisation)
    promotional_feature = create(:promotional_feature, organisation:)
    create(:promotional_feature_item, promotional_feature:)
  end
end

World(PromotionalFeaturesHelper)
