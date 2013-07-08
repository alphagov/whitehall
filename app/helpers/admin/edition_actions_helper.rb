module Admin::EditionActionsHelper
  def edit_edition_button(edition)
    link_to 'Edit', edit_admin_edition_path(edition), title: "Edit #{edition.title}", class: "btn"
  end

  def redraft_edition_button(edition)
    button_to 'Create new edition', revise_admin_edition_path(edition), title: "Create new edition", class: "btn"
  end

  def approve_retrospectively_edition_button(edition)
    confirmation_prompt = "Are you sure you want to retrospectively approve this document?"
    content_tag(:div, class: "approve_retrospectively_button") do
      content_tag(:p, "Does it look ok?") +
        capture do
          form_for [:admin, edition], {
            url: approve_retrospectively_admin_edition_path(edition, lock_version: edition.lock_version),
            method: :post} do |form|
            concat(form.submit "Looks good", confirm: confirmation_prompt, class: "btn btn-success")
          end
      end
    end
  end

  def most_recent_edition_button(edition)
    link_to "Go to most recent edition", admin_edition_path(edition.latest_edition),
            title: "Go to most recent edition of #{edition.title}", class: "btn"
  end

  def submit_edition_button(edition)
    button_to "Submit", submit_admin_edition_path(edition, lock_version: edition.lock_version), class: "btn btn-success"
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
    css_classes = ["btn"]
    css_classes << (options[:force] ? "btn-warning" : "btn-success")
    if options[:force]
      force_publish_path = force_publish_admin_edition_path(edition, options.merge(lock_version: edition.lock_version))
      link_to "Force publish", force_publish_path, {class: css_classes.join(" "), "data-toggle" => "modal", "data-target" => "#forcePublishModal"}
    else
      button_to "Publish", publish_admin_edition_path(edition, options.merge(lock_version: edition.lock_version)), confirm: confirm, title: button_title, class: css_classes.join(" ")
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
    button_to 'Delete', admin_edition_path(edition), method: :delete, title: "Delete", confirm: "Are you sure you want to delete the document?", class: "btn btn-danger"
  end

  def unpublish_edition_button(edition)
    button_to 'Unpublish', confirm_unpublish_admin_edition_path(edition), title: "Unpublish", class: "btn btn-danger", method: :get
  end

  def document_creation_menu
    if can?(:create, Document)
      content_tag(:a, class: "btn btn-large dropdown-toggle", data: {toggle: "dropdown"}, href: "#") do
        %{Create new document
        <span class="caret"></span>}.html_safe
      end + document_creation_dropdown
    end
  end

  def document_creation_dropdown
    content_tag(:ul, class: "dropdown-menu") do
      [Policy, Publication, NewsArticle, FatalityNotice,
        Consultation, Speech, DetailedGuide, WorldwidePriority,
        CaseStudy, StatisticalDataSet, WorldLocationNewsArticle].map do |edition_type|
        content_tag(:li) do
          link_to edition_type.model_name.human.titleize, polymorphic_path([:new, :admin, edition_type.name.underscore]), title: "Create #{edition_type.model_name.human.titleize}"
        end if can?(:create, edition_type)
      end.compact.join.html_safe
    end
  end

  private

  def publish_edition_alerts(edition, force)
    alerts = []
    alerts << "Are you sure you want to force publish this document?" if force
    alerts += supporting_pages_alerts(edition)
    alerts.join(" ")
  end

  def schedule_edition_alerts(edition, force)
    alerts = []
    alerts << "Are you sure you want to force schedule this document for publication?" if force
    alerts += supporting_pages_alerts(edition)
    alerts.join(" ")
  end

  def supporting_pages_alerts(edition)
    if edition.has_supporting_pages?
      ["Have you checked the #{edition.supporting_pages.count} supporting pages?"]
    else
      []
    end
  end
end
