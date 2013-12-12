module EditionFilteringHelper
  def filter_editions_by(filter_name, value)
    ensure_path admin_editions_path
    within ".editions-filter" do
      within "##{filter_name}_filter" do
        select value
      end
      click_on "Search"
    end
  end
end

World(EditionFilteringHelper)
