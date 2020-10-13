ParameterType(
  name: "edition",
  regexp: /the (document|publication|news article|consultation|consultation response|speech|detailed guide|announcement|world location news article|statistical data set|document collection|corporate information page) "([^"]*)"/,
  transformer: ->(document_type, title) { document_class(document_type).latest_edition.find_by!(title: title) },
)

module DocumentHelper
  def document_class(type)
    type = "edition" if type == "document"
    type.tr(" ", "_").classify.constantize
  end

  def set_lead_organisation_on_document(organisation, order = 1)
    select organisation.name, from: "edition_lead_organisation_ids_#{order}"
  end

  def begin_drafting_document(options)
    create(:organisation) if Organisation.count.zero?
    visit admin_root_path
    # Make sure the dropdown is visible first, otherwise Capybara won't see the links
    find("li.create-new a", text: "New document").click
    within "li.create-new" do
      click_link options[:type].humanize
    end

    within "form" do
      fill_in "edition_title", with: options[:title]
      fill_in "edition_body", with: options.fetch(:body, "Any old iron")
      fill_in "edition_summary", with: options.fetch(:summary, "one plus one euals two!")
      fill_in_change_note_if_required
      set_lead_organisation_on_document(Organisation.first)

      if options[:alternative_format_provider]
        select options[:alternative_format_provider].name, from: "edition_alternative_format_provider_id"
      end

      case options[:previously_published]
      when false
        choose "has never been published before. It is new."
      when true
        choose "has previously been published on another website."
      end

      if options[:all_nation_applicability]
        check "Applies to all UK nations"
      end
    end
  end

  def begin_editing_document(title)
    visit_edition_admin title
    click_link "Edit draft"
  end

  def begin_new_draft_document(title)
    visit_edition_admin title
    click_button "Create new edition to edit"
  end

  def begin_drafting_news_article(options)
    begin_drafting_document(options.merge(type: "news_article", previously_published: false))
    fill_in_news_article_fields(options.slice(:first_published, :announcement_type))
  end

  def begin_drafting_consultation(options)
    begin_drafting_document(options.merge(type: "consultation", all_nation_applicability: true))
    select_date 10.days.from_now.to_s, from: "Opening Date"
    select_date 40.days.from_now.to_s, from: "Closing Date"
  end

  def begin_drafting_publication(title, options = {})
    begin_drafting_document(
      type: "publication",
      title: title,
      summary: "Some summary of the content",
      alternative_format_provider: create(:alternative_format_provider),
      all_nation_applicability: options.key?(:all_nation_applicability) ? options[:all_nation_applicability] : true,
    )
    fill_in_publication_fields(options.slice(:first_published, :publication_type))
  end

  def begin_drafting_statistical_data_set(options)
    begin_drafting_document options.merge(type: "statistical_data_set", previously_published: false)
  end

  def begin_drafting_speech(options)
    organisation = create(:ministerial_department)
    person = create_person("Colonel Mustard")
    role = create(:ministerial_role, name: "Attorney General", organisations: [organisation])
    create(:role_appointment, person: person, role: role, started_at: Date.parse("2010-01-01"))
    begin_drafting_document options.merge(type: "speech", summary: "Some summary of the content", previously_published: false)
    select SpeechType::Transcript.singular_name, from: "Speech type"
    select "Colonel Mustard, Attorney General", from: "Speaker"
    select_date 1.day.ago.to_s, from: "Delivered on"
    fill_in "Location", with: "The Drawing Room"
  end

  def begin_drafting_document_collection(options)
    begin_drafting_document options.merge(type: "document_collection", previously_published: false)
  end

  def pdf_attachment
    Rails.root.join("features/fixtures/attachment.pdf")
  end

  def fill_in_news_article_fields(first_published: "2010-01-01", announcement_type: "News story")
    select announcement_type, from: "News article type"
    choose "has previously been published on another website."
    select_date first_published, from: "Its original publication date was *"
  end

  def fill_in_publication_fields(first_published: "2010-01-01", publication_type: "Research and analysis")
    choose "has previously been published on another website."
    select_date first_published, from: "Its original publication date was *"
    select publication_type, from: "edition_publication_type_id"
  end

  def visit_edition_admin(title, scope = :all)
    document = Edition.send(scope).find_by(title: title)
    visit admin_edition_path(document)
  end

  def visit_document_preview(title, scope = :all)
    document = Edition.send(scope).find_by(title: title)
    visit preview_document_path(document)
  end

  def fill_in_change_note_if_required
    if has_selector?("textarea[name='edition[change_note]']", wait: false)
      fill_in "edition_change_note", with: "changes"
    end
  end

  def apply_to_all_nations_if_required
    if has_selector?(".excluded_nations", wait: false)
      check "Applies to all UK nations"
    end
  end

  def refute_flash_alerts_exist
    assert has_no_css?(".flash.alert")
  end

  def publish(options = {})
    if options[:force]
      click_link "Force publish"
      has_selector?(".force-publish-form", visible: true)
      within ".force-publish-form" do
        fill_in "reason", with: "because"
        click_button "Force publish"
      end
    else
      click_button "Publish"
    end

    refute_flash_alerts_exist unless options[:ignore_errors]
  end

  def speed_tag_publication(title)
    edition = Edition.find_by(title: title)
    visit admin_edition_path(edition)

    assert_selector ".speed-tag"
    within ".speed-tag" do
      select "Research and analysis", from: "Publication type"
      click_on "Save"
      assert_no_selector ".speed-tag .alert"
    end
  end

  def convert_to_draft(title)
    edition = Edition.find_by(title: title)
    visit admin_edition_path(edition)

    click_on "Convert to draft"
    assert_no_selector ".speed-tag"
  end
end

World(DocumentHelper)
