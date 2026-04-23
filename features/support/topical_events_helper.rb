ParameterType(
  name: "topical_event_section",
  regexp: /the (announcements|publications|consultations) section/,
  transformer: ->(section) { section },
)
module TopicalEventsHelper
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
