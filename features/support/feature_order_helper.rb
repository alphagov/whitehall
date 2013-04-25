module FeatureOrderHelper
  def order_features_from(table)
    table.raw.each_with_index do |(title), index|
      fill_in title, with: index
    end
    click_button "Update feature order"
  end
end

World(FeatureOrderHelper)
