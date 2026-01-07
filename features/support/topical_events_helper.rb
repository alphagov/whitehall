ParameterType(
  name: "topical_event_section",
  regexp: /the (announcements|publications|consultations) section/,
  transformer: ->(section) { section },
)
module TopicalEventsHelper
  def create_topical_event_and_stub_in_content_store(options = {})
    visit admin_root_path
    click_link "More"
    click_link "Topical events"
    click_link "Create topical event"
    fill_in "Name", with: options[:name] || "topic-name"
    fill_in "Description", with: options[:description] || "topic-description"
    fill_in "Summary", with: options[:description] || "topic-summary"
    within "#topical_event_start_date" do
      fill_in_date_fields(options[:start_date] || 1.day.ago.to_s)
    end
    within "#topical_event_end_date" do
      fill_in_date_fields(options[:end_date] || 1.month.from_now.to_s)
    end

    click_button "Save"

    stub_topical_event_in_content_store(options[:name])
  end

  def stub_topical_event_in_content_store(name)
    content_item = {
      format: "topical_event",
      title: name,
    }

    base_path = TopicalEvent.find_by!(name:).base_path

    stub_content_store_has_item(base_path, content_item)
  end
end

World(TopicalEventsHelper)
