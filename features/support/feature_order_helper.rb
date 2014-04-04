module FeatureOrderHelper
  def order_features_from(table)
    table.raw.each_with_index do |(title), index|
      fill_in title, with: index
    end
    click_button "Save ordering"
  end
end

World(FeatureOrderHelper)
