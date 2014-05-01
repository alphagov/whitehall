module Admin::EditionActionsHelper
  def edit_edition_button(edition)
    link_to 'Edit draft', edit_admin_edition_path(edition), title: "Edit #{edition.title}", class: "btn btn-large"
  end

  def redraft_edition_button(edition)
    button_to 'Create new edition to edit', revise_admin_edition_path(edition), title: "Create new edition to edit", class: "btn btn-large"
  end

  def approve_retrospectively_edition_button(edition)
    confirmation_prompt = "Are you sure you want to retrospectively approve this document?"
    content_tag(:div, class: "approve_retrospectively_button") do
      capture do
        form_for [:admin, edition], {
          url: approve_retrospectively_admin_edition_path(edition, lock_version: edition.lock_version),
          method: :post} do |form|
          concat(form.submit "Looks good", confirm: confirmation_prompt, class: "btn btn-success")
        end
      end
    end
  end

  def submit_edition_button(edition)
    button_to "Submit for 2nd eyes", submit_admin_edition_path(edition, lock_version: edition.lock_version), class: "btn btn-success second-eyes"
  end

  def reject_edition_button(edition)
    button_to "Reject", reject_admin_edition_path(edition, lock_version: edition.lock_version), class: "btn btn-warning"
  end

  def convert_to_draft_edition_form(edition)
    url = convert_to_draft_admin_edition_path(edition, lock_version: edition.lock_version)
    options = { title: "Convert to draft #{edition.title}", class: 'btn btn-success'}
    options.merge!(disabled: 'disabled') unless edition.valid_as_draft?
    button_to 'Convert to draft', url, options
  end

  def publish_edition_form(edition, options = {})
    button_title = "Publish #{edition.title}"
    confirm = publish_edition_alerts(edition, options[:force])
    if options[:force]
      confirm_force_publish_path = confirm_force_publish_admin_edition_path(edition, lock_version: edition.lock_version)
      link_to "Force publish", confirm_force_publish_path, {class: "btn force-publish", "data-toggle" => "modal", "data-target" => "#forcePublishModal"}
    else
      button_to "Publish", publish_admin_edition_path(edition, options.merge(lock_version: edition.lock_version)), confirm: confirm, title: button_title, class: "btn btn-success publish"
    end
  end

  def schedule_edition_form(edition, options = {})
    url = schedule_admin_edition_path(edition, options.slice(:force).merge(lock_version: edition.lock_version))
    button_text = options[:force] ? "Force schedule" : "Schedule"
    button_title = "Schedule #{edition.title} for publication on #{l edition.scheduled_publication, format: :long}"
    confirm = schedule_edition_alerts(edition, options[:force])
    css_classes = ["btn"]
    css_classes << (options[:force] ? "btn-warning" : "btn-success")
    button_to button_text, url, confirm: confirm, title: button_title, class: css_classes.join(" ")
  end

  def unschedule_edition_button(edition)
    confirm = "Are you sure you want to unschedule this edition and return it to the submitted state?"
    button_to "Unschedule",
      unschedule_admin_edition_path(edition, lock_version: edition.lock_version),
      title: "Unschedule this edition to allow changes or prevent automatic publication on #{l edition.scheduled_publication, format: :long}",
      class: "btn btn-warning",
      confirm: confirm
  end

  def delete_edition_button(edition)
    button_to 'Discard draft', admin_edition_path(edition), method: :delete, title: "Delete", confirm: "Are you sure you want to discard this draft?", class: "btn btn-danger"
  end

  # If adding new models also update filter_options_for_edition
  def document_creation_dropdown
    content_tag(:ul, class: "more-nav left js-hidden") do
      [Consultation, Publication, NewsArticle,
        Speech, DetailedGuide, DocumentCollection,
        Policy, SupportingPage, FatalityNotice,
        WorldwidePriority, CaseStudy, StatisticalDataSet,
        WorldLocationNewsArticle].map do |edition_type|
        content_tag(:li) do
          link_to edition_type.model_name.human, polymorphic_path([:new, :admin, edition_type.name.underscore]), title: "Create #{edition_type.model_name.human.titleize}"
        end if can?(:create, edition_type)
      end.compact.join.html_safe
    end
  end

  def filter_edition_type_options_for_select(user, selected)
    options_for_select([["All types", ""]]) + edition_type_options_for_select(user, selected) + edition_sub_type_options_for_select(selected)
  end

  private

  def edition_type_options_for_select(user, selected)
    type_options_container = Whitehall.edition_classes.map do |edition_type|
      unless edition_type == FatalityNotice && !user.can_handle_fatalities?
        [edition_type.model_name.human.pluralize, edition_type.model_name.underscore]
      end
    end

    options_for_select(type_options_container, selected)
  end

  def edition_sub_type_options_for_select(selected)
    subtype_options_hash = {
      'Publication sub-types' => PublicationType.ordered_by_prevalence.map { |sub_type| [sub_type.plural_name, "publication_#{sub_type.id}"] },
      'News article sub-types' => NewsArticleType.ordered_by_prevalence.map { |sub_type| [sub_type.plural_name, "news_article_#{sub_type.id}"] },
      'Speech sub-types' => SpeechType.all.map { |sub_type| [sub_type.plural_name, "speech_#{sub_type.id}"] }
    }
    grouped_options_for_select(subtype_options_hash, selected)
  end

  def publish_edition_alerts(edition, force)
    alerts = []
    alerts << "Are you sure you want to force publish this document?" if force
    alerts.join(" ")
  end

  def schedule_edition_alerts(edition, force)
    alerts = []
    alerts << "Are you sure you want to force schedule this document for publication?" if force
    alerts.join(" ")
  end
end
