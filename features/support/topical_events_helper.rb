module TopicalEventsHelper
  def create_topical_event_and_stub_in_content_store(options = {})
    visit admin_root_path
    click_link "Topical events"
    click_link "Create topical event"
    fill_in "Name", with: options[:name] || "topic-name"
    fill_in "Description", with: options[:description] || "topic-description"
    select_date (options[:start_date] || 1.day.ago.to_s), from: "Start Date"
    select_date (options[:end_date] || 1.month.from_now.to_s), from: "End Date"
    click_button "Save"

    stub_topical_event_in_content_store(options[:name])
  end

  def create_recently_published_documents_for_topical_event(event)
    sample_document_types_and_titles.each.with_index do |(type, title), index|
      create(:"published_#{type}",
             title: title,
             first_published_at: index.days.ago,
             topical_events: [event])
    end
  end

  def sample_document_types_and_titles
    {
      policy_paper: 'Policy on Topicals',
      consultation: 'Examination of Events',
      news_story: 'PM attends summit on topical events',
      statistics: 'Weekly topical event prices'
    }
  end

  def rummager_response
    File.read(Rails.root.join('features/fixtures/rummager_response.json'))
  end

  def stub_topical_event_in_content_store(name)
    content_item = {
      format: "topical_event",
      title: name,
    }

    base_path = topical_event_path(TopicalEvent.find_by!(name: name))

    content_store_has_item(base_path, content_item)
  end
end

World(TopicalEventsHelper)
