THE_DOCUMENT = Transform(/the (document|publication|policy|news article|consultation|consultation response|speech|international priority|specialist guide) "([^"]*)"/) do |document_type, title|
  document_class(document_type).latest_edition.find_by_title!(title)
end

module DocumentHelper
  def document_class(type)
    type = 'edition' if type == 'document'
    type.gsub(" ", "_").classify.constantize
  end

  def begin_drafting_document(options)
    visit admin_editions_path
    click_link "Create #{options[:type].titleize}"
    fill_in "Title", with: options[:title]
    fill_in "Body", with: options[:body] || "Any old iron"
  end

  def begin_drafting_policy(options)
    organisation = create(:organisation, name: "Ministry of Silly", alternative_format_contact_email: "alternatives@silly.gov.uk")
    begin_drafting_document(options.merge(type: "policy"))
    fill_in "Summary", with: options[:summary] || "Policy summary"
    select organisation.name, from: "edition_alternative_format_provider_id"
  end

  def begin_editing_document(title)
    visit_document_preview title
    click_link "Edit"
  end

  def begin_new_draft_document(title)
    visit_document_preview title
    click_button "Create new edition"
  end

  def begin_drafting_publication(title)
    policy = create(:policy)
    begin_drafting_document type: 'publication', title: title
    fill_in_publication_fields
    select policy.title, from: "Related policies"
  end

  def begin_drafting_speech(options)
    person = create_person("Colonel Mustard")
    role = create(:ministerial_role, name: "Attorney General")
    role_appointment = create(:role_appointment, person: person, role: role, started_at: Date.parse('2010-01-01'))
    speech_type = SpeechType::Transcript
    begin_drafting_document options.merge(type: 'speech')
    select speech_type.name, from: "Type"
    select "Colonel Mustard, Attorney General", from: "Delivered by"
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
    select "Research and analysis", from: "Publication type"
    fill_in "Summary", with: "Some summary of the content"
  end

  def visit_document_preview(title, scope = :scoped)
    document = Edition.send(scope).find_by_title(title)
    visit admin_edition_path(document)
  end

  def fill_in_change_note_if_required
    if has_css?("textarea[name='edition[change_note]']")
      fill_in "Change note", with: "changes"
    end
  end

  def refute_flash_alerts_exist
    refute has_css?(".flash.alert")
  end

  def publish(options = {})
    click_button options[:force] ? "Force Publish" : "Publish"
    unless options[:ignore_errors]
      refute_flash_alerts_exist
    end
  end
end

World(DocumentHelper)
