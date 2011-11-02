module DocumentHelper
  def document_class(type)
    type.gsub(" ", "_").classify.constantize
  end

  def begin_drafting_document(options)
    visit admin_documents_path
    click_link "Create #{options[:type].titleize}"
    fill_in "Title", with: options[:title]
    fill_in "Body", with: options[:body] || "Any old iron"
  end

  def begin_editing_document(title)
    visit_document_preview title
    click_link "Edit"
  end

  def begin_new_draft_document(title)
    visit_document_preview title
    click_button "Create new draft"
  end

  def visit_document_preview(title)
    document = Document.find_by_title(title)
    visit admin_document_path(document)
  end
end

World(DocumentHelper)