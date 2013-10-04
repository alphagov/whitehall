module TopicsHelper
  def create_topic(options = {})
    visit admin_root_path
    click_link "Topics"
    click_link "Create topic"
    fill_in "Name", with: options[:name] || "topic-name"
    fill_in "Description", with: options[:description] || "topic-description"
    (options[:related_classifications] || []).each do |related_name|
      select related_name, from: "Related topics"
    end
    click_button "Save"
  end
end

World(TopicsHelper)
