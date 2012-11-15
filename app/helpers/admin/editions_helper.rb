module Admin::EditionsHelper
  def nested_attribute_destroy_checkbox_options(form)
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [{ checked: checked }, checked_value, unchecked_value]
  end

  def admin_documents_header_link
    admin_header_link "Documents", admin_editions_path, /^#{Whitehall.router_prefix}\/admin\/(editions|publications|policies|news_articles|consultations|speeches)/
  end

  def link_to_filter(link, options, html_options={})
    content_tag(:li, link_to(link, url_for(params.slice('state', 'type', 'author', 'organisation', 'title').merge(options)), html_options), class: filter_class(options))
  end

  def filter_class(options)
    current = options.keys.all? do |key|
      options[key].to_param == params[key].to_param
    end

    'active' if current
  end

  def viewing_all_active_editions?
    params[:state] == 'active'
  end

  class EditionFormBuilder < Whitehall::FormBuilder
    def alternative_format_provider_select
      if object.respond_to?(:alternative_format_provider)
        select_options = @template.options_for_select(
          Organisation.all.map {|o| ["#{o.name} (#{o.alternative_format_contact_email || "-"})", o.id]},
          selected: object.alternative_format_provider_id,
          disabled: Organisation.all.reject {|o| o.alternative_format_contact_email.present?}.map(&:id))
        @template.content_tag(:div, class: 'control-group') do
          label(:alternative_format_provider_id, "Email address for ordering this #{object.format_name} in an alternative format") +
            @template.content_tag(:div, class: 'controls') do
              select(
                :alternative_format_provider_id,
                select_options,
                {include_blank: true, multiple: false},
                class: 'chzn-select',
                data: { placeholder: "Choose which organisation will provide alternative formats..." }
              ) + @template.content_tag(:p, "If the email address you need isn't here, it should be added to the relevant Department or Agency", class: 'help-block')
            end
        end
      end
    end
  end

  def standard_edition_form(edition, &blk)
    form_for [:admin, edition], as: :edition, builder: EditionFormBuilder do |form|
      concat form.errors
      concat render(partial: "standard_fields",
                    locals: {form: form, edition: edition})
      yield(form)
      concat render(partial: "scheduled_publication_fields",
                    locals: {form: form, edition: edition})
      concat standard_edition_publishing_controls(form, edition)
    end
  end

  def standard_edition_publishing_controls(form, edition)
    content_tag(:div, class: "publishing-controls well") do
      if edition.change_note_required?
      concat render(partial: "change_notes",
                    locals: {form: form, edition: edition})
      end
      concat form.save_or_cancel
    end
  end

  def mainstream_category_options(edition, selected)
    grouped_options = MainstreamCategory.all.group_by {|c| c.parent_title}.map do |group, members|
      [group, members.map {|c| [c.title, c.id]}]
    end
    grouped_options_for_select(grouped_options, selected, "")
  end
end
