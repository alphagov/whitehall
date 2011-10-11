module DocumentHelper
  def begin_drafting_document(options)
    visit admin_documents_path
    click_link "Draft new #{options[:type].capitalize}"
    fill_in "Title", with: options[:title]
    fill_in "Policy", with: "Any old iron"
  end

  def begin_editing_document(title)
    visit_document_preview title
    click_link "Edit"
  end

  def visit_document_preview(title)
    document = Document.find_by_title(title)
    visit admin_document_path(document)
  end
end

World(DocumentHelper)