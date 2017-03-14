module TopicsHelper
  def create_topic_and_stub_content_store(options = {})
    start_creating_topic(options)
    save_document
  end

  def start_creating_topic(options = {})
    visit admin_root_path
    click_link "Policy Areas"
    click_link "Create policy area"
    fill_in "Name", with: options[:name] || "topic-name"
    fill_in "Description", with: options[:description] || "topic-description"
    (options[:related_classifications] || []).each do |related_name|
      select related_name, from: "Related policy areas"
    end
  end

  def stub_topic_in_content_store(name)
    content_item = { format: "topic", title: name }
    base_path = topic_path(Topic.find_by!(name: name))
    content_store_has_item(base_path, content_item)
  end
end

World(TopicsHelper)
