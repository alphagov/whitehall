module DocumentHelper
  def begin_drafting_document(options)
    visit admin_documents_path
    click_link "Draft new #{options[:type].capitalize}"
    fill_in "Title", with: options[:title]
    fill_in "Policy", with: "Any old iron"
  end
end

World(DocumentHelper)