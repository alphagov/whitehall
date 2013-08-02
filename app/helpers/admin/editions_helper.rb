module Admin::EditionsHelper
  def render_publication_date(edition)
    if edition.publication_date.nil?
      'to be set'
    else
      edition.publication_date.to_s(:long_ordinal)
    end
  end

  def edition_description(edition)
    if (@edition.is_a?(Speech) && @edition.speech_type.written_article?)
      type_description = @edition.speech_type.name.humanize.downcase
    else
      type_description = @edition.type.underscore.humanize.downcase
    end

    "#{@edition.state.capitalize} #{type_description}"
  end

  def nested_attribute_destroy_checkbox_options(form, html_args = {})
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [html_args.merge({ checked: checked }), checked_value, unchecked_value]
  end

  def admin_documents_header_link
    admin_header_link "Documents", admin_editions_path, /^#{Whitehall.router_prefix}\/admin\/(editions|publications|policies|news_articles|consultations|speeches)/
  end

  def admin_document_series_header_link
    admin_header_link "Document series", admin_document_series_index_path, /^#{Whitehall.router_prefix}\/admin\/document_series/
  end

  def link_to_filter(link, options, filter, html_options = {})
    content_tag(:li, link_to(link, url_for(filter.options.slice('state', 'type', 'author', 'organisation', 'title', 'world_location_ids').merge(options)), html_options), class: active_filter_if_options_match_class(filter, options))
  end

  def active_filter_if_options_match_class(filter, options)
    current = options.keys.all? do |key|
      options[key].to_param == filter.options[key].to_param
    end

    'active' if current
  end

  def active_filter_unless_values_match_class(filter, key, *disallowed_values)
    filter_value = filter.options[key]
    'active' if filter_value && disallowed_values.none? { |disallowed_value| filter_value == disallowed_value }
  end

  def pass_through_filter_options_as_hidden_fields(filter, *options_to_pass)
    options_to_pass.map { |option_to_pass|
      value = filter.options[option_to_pass]
      pass_through_filter_value_as_hidden_field(option_to_pass, value)
    }.join.html_safe
  end

  def pass_through_filter_value_as_hidden_field(filter_name, filter_value)
    return '' unless filter_value
    if filter_value.is_a?(Array)
      filter_value.map { |value_to_pass|
        hidden_field_tag "#{filter_name}[]", value_to_pass
      }.join.html_safe
    else
      hidden_field_tag filter_name, filter_value
    end
  end

  def viewing_all_active_editions?
    params[:state] == 'active'
  end

  def speech_type_label_data
    label_data = SpeechType.all.map do |speech_type|
      [ speech_type.id,
        { ownerGroup: I18n.t("document.speech.#{speech_type.owner_key_group}"),
          publishedExternallyLabel: t_delivered_on(speech_type),
          locationRelevant: speech_type.location_relevant }
      ]
    end
    Hash[label_data]
  end

  class EditionFormBuilder < Whitehall::FormBuilder
    def alternative_format_provider_select(alternative_format_required)
      if object.respond_to?(:alternative_format_provider)
        select_options = @template.options_for_select(
          organisations_for_edition_organisations_fields.map {|o| ["#{o.name} (#{o.alternative_format_contact_email || "-"})", o.id]},
          selected: object.alternative_format_provider_id,
          disabled: organisations_for_edition_organisations_fields.reject { |o| o.alternative_format_contact_email.present? }.map(&:id))
        @template.content_tag(:div, class: 'control-group') do
          label(:alternative_format_provider_id, "Email address for ordering attached files in an alternative format", required: alternative_format_required) +
            @template.content_tag(:div, class: 'controls') do
              select(
                :alternative_format_provider_id,
                select_options,
                { include_blank: true, multiple: false },
                class: 'chzn-select',
                data: { placeholder: "Choose which organisation will provide alternative formats..." }
              ) + @template.content_tag(:p, "If the email address you need isn't here, it should be added to the relevant Department or Agency", class: 'help-block')
            end
        end
      end
    end

    def lead_organisations_fields
      edition_organisations =
        object.edition_organisations.
          select { |eo| eo.lead? }.
          sort_by { |eo| eo.lead_ordering }

      edition_organisations_fields(edition_organisations, true)
    end

    def supporting_organisations_fields
      edition_organisations =
        object.edition_organisations.
          reject { |eo| eo.lead? }

      edition_organisations_fields(edition_organisations, false)
    end

    protected
    def edition_organisations_fields(edition_organisations, lead = true)
      field_identifier = lead ? 'lead' : 'supporting'
      edition_organisations.map.with_index { |eo, idx|
        select_options = @template.options_from_collection_for_select(organisations_for_edition_organisations_fields, 'id', 'select_name', eo.organisation_id)
        @template.label_tag "edition_#{field_identifier}_organisation_ids_#{idx + 1}" do
          [
            "Organisation #{idx + 1}",
            @template.select_tag("edition[#{field_identifier}_organisation_ids][]",
                                 select_options,
                                 include_blank: true,
                                 multiple: false,
                                 class: 'chzn-select-non-ie',
                                 data: { placeholder: "Choose a #{field_identifier} organisation which produced this document..." },
                                 id: "edition_#{field_identifier}_organisation_ids_#{idx + 1}"),
          ].join.html_safe
        end
      }.join.html_safe
    end
    def organisations_for_edition_organisations_fields
      @organisations_for_edition_organisations_fields ||= Organisation.with_translations.all
    end
  end

  def standard_edition_form(edition, &blk)
    form_for [:admin, edition], as: :edition, builder: EditionFormBuilder,
              html: { class: ('js-supports-non-english' if edition.locale_can_be_changed?) } do |form|
      concat render('locale_fields', form: form, edition: edition)
      concat edition_information(@information) if @information
      concat form.errors
      concat render(partial: "standard_fields",
                    locals: { form: form, edition: edition })
      yield(form)
      concat render('access_limiting_fields', form: form, edition: edition)
      concat render(partial: "scheduled_publication_fields",
                    locals: { form: form, edition: edition })
      concat standard_edition_publishing_controls(form, edition)
    end
  end

  def tab_url_for_edition(edition)
    if edition.new_record?
      url_for([:new, :admin, edition.class.model_name.underscore])
    else
      url_for([:edit, :admin, edition])
    end
  end

  def default_edition_tabs(edition)
    { 'Document' => tab_url_for_edition(edition) }.tap do |tabs|
      tabs['Attachments'] = admin_edition_attachments_path(edition) if edition.persisted? && edition.allows_attachments?
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

  def mainstream_category_options(edition, selected)
    grouped_options = MainstreamCategory.all.group_by {|c| c.parent_title}.map do |group, members|
      [group, members.map {|c| [c.title, c.id]}]
    end
    grouped_options_for_select(grouped_options, selected, "")
  end

  def warn_about_lack_of_contacts_in_body?(edition)
    if edition.is_a?(NewsArticle) && edition.news_article_type == NewsArticleType::PressRelease
      (govspeak_embedded_contacts(edition.body).size < 1)
    else
      false
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
end
