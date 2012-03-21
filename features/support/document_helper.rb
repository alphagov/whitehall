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

  def begin_drafting_policy(options)
    begin_drafting_document(options.merge(type: "policy"))
    fill_in "Summary", with: options[:summary] || "Policy summary"
  end

  def begin_editing_document(title)
    visit_document_preview title
    click_link "Edit"
  end

  def begin_new_draft_document(title)
    visit_document_preview title
    click_button "Create new edition"
  end

  def begin_drafting_speech(options)
    person = create_person("Colonel Mustard")
    role = create(:ministerial_role, name: "Attorney General")
    role_appointment = create(:role_appointment, person: person, role: role)
    speech_type = SpeechType::Transcript
    begin_drafting_document options.merge(type: 'speech')
    select speech_type.name, from: "Type"
    select "Colonel Mustard (Attorney General)", from: "Delivered by"
    select_date "Delivered on", with: 1.day.ago.to_s
    fill_in "Location", with: "The Drawing Room"
    fill_in "Summary", with: "Some summary of the content"
  end

  def pdf_attachment
    File.open(Rails.root.join("features/fixtures/attachment.pdf"))
  end

  def jpg_image
    File.open(Rails.root.join("features/fixtures/portas-review.jpg"))
  end

  def fill_in_publication_fields
    select_date "Publication date", with: "2010-01-01"
    fill_in "Unique reference", with: "ABC-123"
    fill_in "ISBN", with: "0099532816"
    check "Research?"
    fill_in "Order URL", with: "http://example.com/order-url"
    fill_in "Summary", with: "Some summary of the content"
  end

  def visit_document_preview(title, scope = :scoped)
    document = Document.send(scope).find_by_title(title)
    visit admin_document_path(document)
  end

  def publishing_requires_change_note?
    has_css?("textarea[name='document[change_note]']")
  end

  def refute_flash_alerts_exist
    refute has_css?(".flash.alert")
  end

  def publish(options = {})
    if publishing_requires_change_note?
      if options[:minor_change]
        check "Minor change?"
      elsif !options[:without_change_note]
        fill_in "Change note", with: "Fixed some grammatical errors."
      end
    end
    click_button options[:force] ? "Force Publish" : "Publish"
    unless options[:ignore_errors]
      refute_flash_alerts_exist
    end
  end
end

World(DocumentHelper)
