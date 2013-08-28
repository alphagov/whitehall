module EditionFilteringHelper
  def filter_editions_by(filter_name, value)
    ensure_path admin_editions_path
    within "##{filter_name}_filter" do
      select value
      click_button 'Go'
    end
  end
end

World(EditionFilteringHelper)
