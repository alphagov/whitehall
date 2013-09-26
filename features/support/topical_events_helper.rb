module TopicalEventsHelper
  def create_topical_event(options = {})
    visit admin_root_path
    click_link "Topical events"
    click_link "Create topical event"
    fill_in "Name", with: options[:name] || "topic-name"
    fill_in "Description", with: options[:description] || "topic-description"
    select_date (options[:start_date] || 1.day.ago.to_s), from: "Start Date"
    select_date (options[:end_date] || 1.month.from_now.to_s), from: "End Date"
    click_button "Save"
  end
end

World(TopicalEventsHelper)
