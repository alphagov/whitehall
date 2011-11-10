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

  def begin_drafting_speech(options)
    person = create(:person, name: "Colonel Mustard")
    role = create(:ministerial_role, name: "Attorney General")
    role_appointment = create(:role_appointment, person: person, role: role)
    begin_drafting_document options.merge(type: 'speech')
    select "Draft Text", from: "Type"
    select "Colonel Mustard (Attorney General)", from: "Delivered by"
    select_date "Delivered on", with: 1.day.ago.to_s
    fill_in "Location", with: "The Drawing Room"
  end

  def visit_document_preview(title)
    document = Document.find_by_title(title)
    visit admin_document_path(document)
  end
end

World(DocumentHelper)