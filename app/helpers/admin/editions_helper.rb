module Admin::EditionsHelper

  def edition_type(edition)
    if (edition.is_a?(Speech) && edition.speech_type.written_article?)
      type = edition.speech_type.singular_name
    else
      type = edition.type.underscore.humanize
    end

    [type, edition.display_type].compact.uniq.join(": ")
  end

  def nested_attribute_destroy_checkbox_options(form, html_args = {})
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [html_args.merge({ checked: checked }), checked_value, unchecked_value]
  end

  def admin_documents_header_link
    admin_header_link "Documents", admin_editions_path, /^#{Whitehall.router_prefix}\/admin\/(editions|publications|news_articles|consultations|speeches|collections)/
  end

  def active_filter_if_options_match_class(filter, options)
    current = options.keys.all? do |key|
      options[key].to_param == filter.options[key].to_param
    end

    'active' if current
  end

  def admin_organisation_filter_options(current_user, selected_organisation)
    organisations = Organisation.with_translations(:en).order(:name).excluding_govuk_status_closed || []
    closed_organisations = Organisation.with_translations(:en).closed || []
    if current_user.organisation
        organisations = [current_user.organisation] + (organisations - [current_user.organisation])
    end

    options_for_select([["All organisations", ""]], selected_organisation) +
    grouped_options_for_select(
      [
        ["Live organisations", organisations.map { |o| [o.select_name, o.id] }],
        ["Closed organisations", closed_organisations.map { |o| [o.select_name, o.id] }]
      ],
      selected_organisation
    )
  end

  def admin_author_filter_options(current_user)
    other_users = User.enabled.to_a - [current_user]
    [["All authors", ""], ["Me", current_user.id]] + other_users.map { |u| [u.name, u.id] }
  end

  def admin_state_filter_options
    [
      ["All states", 'active'],
      ["Imported (pre-draft)", 'imported'],
      ["Draft", 'draft'],
      ["Submitted", 'submitted'],
      ["Rejected", 'rejected'],
      ["Scheduled", 'scheduled'],
      ["Published", 'published'],
      ["Force published (not reviewed)", 'force_published'],
      ['Withdrawn', 'withdrawn']
    ]
  end

  def admin_edition_state_text(edition)
    edition.withdrawn? ? 'Withdrawn' : edition.state.humanize
  end

  def admin_world_location_filter_options(current_user)
    options = [["All locations", ""]]
    if current_user.world_locations.any?
      options << ["My locations", "user"]
    end
    options + WorldLocation.ordered_by_name.map { |l| [l.name, l.id] }
  end

  def viewing_all_active_editions?
    params[:state] == 'active'
  end

  def speech_type_label_data
    label_data = SpeechType.all.inject({}) do |hash, speech_type|
      hash.merge(speech_type.id => {
        ownerGroup: I18n.t("document.speech.#{speech_type.owner_key_group}"),
        publishedExternallyLabel: t_delivered_on(speech_type),
        locationRelevant: speech_type.location_relevant
      })
    end

    imported_type = SpeechType.find_by_name('Imported - Awaiting Type')
    label_data.merge('' => {
        ownerGroup: I18n.t("document.speech.#{imported_type.owner_key_group}"),
        publishedExternallyLabel: t_delivered_on(imported_type),
        locationRelevant: imported_type.location_relevant
      })
  end

  # Because of the unusual way lead organisations and supporting organisations
  # are managed through the single has_many through :organisations association,
  # We have to go through the join model to identify selected organisations
  # when rendering editions' organisation select fields. See the
  # Edition::Organisations mixin module to see why this is required.
  def lead_organisation_id_at_index(edition, index)
    edition.edition_organisations.
            select { |eo| eo.lead? }.
            sort_by { |eo| eo.lead_ordering }[index].try(:organisation_id)
  end

  # As above for the lead_organisation_id_at_index helper, this helper is
  # required to identify the selected supporting organisation at a given index
  # in the list supporting organisations for the edition.
  def supporting_organisation_id_at_index(edition, index)
    edition.edition_organisations.reject { |eo| eo.lead? }[index].try(:organisation_id)
  end

  def standard_edition_form(edition, &blk)
    initialise_script "GOVUK.adminEditionsForm", selector: '.js-edition-form', right_to_left_locales: Locale.right_to_left.collect(&:to_param)

    form_classes = ["edition-form js-edition-form"]
    form_classes << 'js-supports-non-english' if edition.locale_can_be_changed?

    form_for form_url_for_edition(edition), as: :edition, html: { class: form_classes } do |form|
      concat render('locale_fields', form: form, edition: edition)
      concat edition_information(@information) if @information
      concat form.errors
      concat render("standard_fields", form: form, edition: edition)
      yield(form)
      concat render('access_limiting_fields', form: form, edition: edition)
      concat render("scheduled_publication_fields", form: form, edition: edition)
      concat standard_edition_publishing_controls(form, edition)
    end
  end

  def form_url_for_edition(edition)
    if edition.is_a? CorporateInformationPage
      [:admin, edition.owning_organisation, edition]
    else
      [:admin, edition]
    end
  end

  def tab_url_for_edition(edition)
    if edition.is_a? CorporateInformationPage
      if edition.new_record?
        url_for([:new, :admin, @organisation, edition.class.model_name.param_key])
      else
        url_for([:edit, :admin, edition.owning_organisation, edition])
      end
    else
      if edition.new_record?
        url_for([:new, :admin, edition.class.model_name.param_key])
      else
        url_for([:edit, :admin, edition])
      end
    end
  end

  def default_edition_tabs(edition)
    { 'Document' => tab_url_for_edition(edition) }.tap do |tabs|
      if edition.allows_attachments? && edition.persisted?
        text = if edition.attachments.count > 0
          "Attachments <span class='badge'>#{edition.attachments.count}</span>".html_safe
        else
          "Attachments"
        end
        tabs[text] = admin_edition_attachments_path(edition)
      end

      if edition.is_a?(DocumentCollection) && !edition.new_record?
        tabs["Collection documents"] = admin_document_collection_groups_path(edition)
      end
    end
  end

  def edition_editing_tabs(edition, &blk)
    tabs = default_edition_tabs(edition)
    tab_navigation(tabs) { yield blk }
  end

  def consultation_editing_tabs(edition, &blk)
    tabs = default_edition_tabs(edition)
    if edition.persisted?
      tabs['Public feedback'] = admin_consultation_public_feedback_path(edition)
      tabs['Final outcome'] = admin_consultation_outcome_path(edition)
    end
    tab_navigation(tabs) { yield blk }
  end

  def edition_edit_headline(edition)
    if edition.is_a?(CorporateInformationPage)
      "Edit &lsquo;#{edition.title}&rsquo; page for #{link_to edition.owning_organisation.name, [:admin, edition.owning_organisation]}".html_safe
    else
      "Edit #{edition.type.underscore.humanize.downcase}"
    end
  end

  def edition_information(information)
    content_tag(:div, class: "alert alert-info") do
      information
    end
  end

  def standard_edition_publishing_controls(form, edition)
    content_tag(:div, class: "publishing-controls well") do
      if edition.change_note_required?
        concat render(partial: "change_notes",
                      locals: { form: form, edition: edition })
      end
      concat form.save_or_continue_or_cancel
    end
  end

  def warn_about_lack_of_contacts_in_body?(edition)
    if edition.is_a?(NewsArticle) && edition.news_article_type == NewsArticleType::PressRelease
      (govspeak_embedded_contacts(edition.body).size < 1)
    else
      false
    end
  end

  def attachment_virus_status(attachment)
    if attachment.could_contain_viruses?
      case attachment.virus_status
      when :clean
        nil
      when :pending
        content_tag(:p, "Virus scanning", class: "virus-scanning")
      else
        content_tag(:p, "Virus found", class: "virus")
      end
    end
  end

  def attachment_metadata_tag(attachment)
    labels = {
      isbn: 'ISBN',
      unique_reference: 'Unique reference',
      command_paper_number: 'Command paper number',
      order_url: 'Order URL',
      price: 'Price',
      hoc_paper_number: 'House of Commons paper number',
      parliamentary_session: 'Parliamentary session'
    }
    parts = []
    labels.each do |attribute, label|
      value = attachment.send(attribute)
      parts << "#{label}: #{value}" if value.present?
    end
    content_tag(:p, parts.join(', ')) if parts.any?
  end

  def translation_preview_links(edition)
    links = []

    if edition.available_in_english?
      links << [preview_document_url(edition), 'Language: English']
    end

    links + edition.non_english_translated_locales.map do |locale|
      [preview_document_url(edition, locale: locale),
       "Language: #{locale.native_and_english_language_name}"]
    end
  end

  def withdrawal_or_unpublishing(edition)
    edition.unpublishing.unpublishing_reason_id == UnpublishingReason::Withdrawn.id ? 'withdrawal' : 'unpublishing'
  end

  def specialist_sector_options_for_select
    @specialist_sector_options_for_select ||= LinkableTopics.new.topics
  end

  def show_similar_slugs_warning?(edition)
    !edition.document.published? && edition.document.similar_slug_exists?
  end
end
