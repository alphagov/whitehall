module Admin::EditionActionsHelper
  def edit_edition_button(edition)
    link_to 'Edit draft', edit_admin_edition_path(edition), title: "Edit #{edition.title}", class: "btn btn-default btn-lg add-left-margin"
  end

  def redraft_edition_button(edition)
    button_to 'Create new edition to edit', revise_admin_edition_path(edition), title: "Create new edition to edit", class: "btn btn-default btn-lg"
  end

  def approve_retrospectively_edition_button(edition)
    confirmation_prompt = "Are you sure you want to retrospectively approve this document?"
    content_tag(:div, class: "approve_retrospectively_button") do
      capture do
        form_for [:admin, edition], {
          url: approve_retrospectively_admin_edition_path(edition, lock_version: edition.lock_version),
          method: :post } do |form|
          concat(form.submit "Looks good", data: { confirm: confirmation_prompt }, class: "btn btn-success")
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
    options = { title: "Convert to draft #{edition.title}", class: 'btn btn-success' }
    options.merge!(disabled: 'disabled') unless edition.valid_as_draft?
    button_to 'Convert to draft', url, options
  end

  def publish_edition_form(edition, options = {})
    button_title = "Publish #{edition.title}"

    if options[:force]
      link_to("Force publish",
              confirm_force_publish_admin_edition_path(edition, lock_version: edition.lock_version),
              title: button_title,
              class: "btn btn-default force-publish",
              "data-module" => "linked-modal",
              "data-target" => "#forcePublishModal")
    else
      button_to("Publish",
                publish_admin_edition_path(edition, lock_version: edition.lock_version),
                title: button_title,
                class: "btn btn-success publish")
    end
  end

  def schedule_edition_form(edition, options = {})
    button_title = "Schedule #{edition.title} for publication on #{l edition.scheduled_publication, format: :long}"

    if options[:force]
      button_to("Force schedule",
                force_schedule_admin_edition_path(edition, lock_version: edition.lock_version),
                data: { confirm: "Are you sure you want to force schedule this document for publication?" },
                title: button_title,
                class: "btn btn-warning")
    else
      button_to("Schedule",
                schedule_admin_edition_path(edition, lock_version: edition.lock_version),
                title: button_title,
                class: "btn btn-success")
    end
  end

  def unschedule_edition_button(edition)
    confirm = "Are you sure you want to unschedule this edition and return it to the submitted state?"
    button_to "Unschedule",
      unschedule_admin_edition_path(edition, lock_version: edition.lock_version),
      title: "Unschedule this edition to allow changes or prevent automatic publication on #{l edition.scheduled_publication, format: :long}",
      class: "btn btn-warning",
      data: { confirm: confirm }
  end

  def delete_edition_button(edition)
    button_to 'Discard draft', admin_edition_path(edition), method: :delete, title: "Delete", data: { confirm: "Are you sure you want to discard this draft?" }, class: "btn btn-danger"
  end

  # If adding new models also update filter_options_for_edition
  def document_creation_dropdown
    content_tag(:ul,
      class: "masthead-menu list-unstyled js-hidden",
      id: 'new-document-menu',
      role: 'menu',
      'aria-labelledby' => 'new-document-label') do
      edition_types = [
        Consultation,
        Publication,
        NewsArticle,
        Speech,
        DetailedGuide,
        DocumentCollection,
        FatalityNotice,
        CaseStudy,
        StatisticalDataSet,
      ]
      edition_types.map do |edition_type|
        content_tag(:li, class: 'masthead-menu-item') do
          link_to(edition_type.model_name.human,
            polymorphic_path([:new, :admin, edition_type.name.underscore]),
            title: "Create #{edition_type.model_name.human.titleize}",
            role: 'menuitem')
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
        [edition_type.model_name.human.pluralize, edition_type.model_name.singular]
      end
    end
ActiveModel::Name
    options_for_select(type_options_container, selected)
  end

  def edition_sub_type_options_for_select(selected)
    subtype_options_hash = {
      'Publication sub-types' => PublicationType.ordered_by_prevalence.map { |sub_type| [sub_type.plural_name, "publication_#{sub_type.id}"] },
      'News article sub-types' => NewsArticleType.all.map { |sub_type| [sub_type.plural_name, "news_article_#{sub_type.id}"] },
      'Speech sub-types' => SpeechType.all.map { |sub_type| [sub_type.plural_name, "speech_#{sub_type.id}"] }
    }
    grouped_options_for_select(subtype_options_hash, selected)
  end
end
