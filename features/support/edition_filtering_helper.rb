module EditionFilteringHelper
  def filter_editions_by(filter_name, value)
    ensure_path admin_editions_path
    filter_selector = using_design_system? ? ".app-view-filter" : ".filter-options"
    within filter_selector do
      within "##{filter_name}_filter" do
        select value
      end
      click_on "Search"
    end
  end
end

World(EditionFilteringHelper)
