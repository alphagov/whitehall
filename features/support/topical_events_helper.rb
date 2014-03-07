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

  def create_recently_published_documents_for_topical_event(event)
    sample_document_types_and_titles.each.with_index do |(type, title), index|
      create(:"published_#{type}",
             title: title,
             first_published_at: index.days.ago,
             topical_events: [event])
    end
  end

  def sample_document_types_and_titles
    documents = {
      policy_paper: 'Policy on Topicals',
      consultation: 'Examination of Events',
      policy: 'Keeping the UK Topical',
      news_story: 'PM attends summit on topical events',
      statistics: 'Weekly topical event prices'
    }
  end
end

World(TopicalEventsHelper)
