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
    button_to "Submit to 2nd pair of eyes", submit_admin_edition_path(edition, lock_version: edition.lock_version), class: "btn btn-success"
  end

  def reject_edition_button(edition)
    button_to "Reject", reject_admin_edition_path(edition, lock_version: edition.lock_version), class: "btn btn-warning"
  end

  def convert_to_draft_edition_form(edition)
    url = convert_to_draft_admin_edition_path(edition, lock_version: edition.lock_version)
    button_to 'Convert to draft', url, title: "Convert to draft #{edition.title}", class: 'btn btn-success'
  end

  def publish_edition_form(edition, options = {})
    url = publish_admin_edition_path(edition, options.slice(:force).merge(lock_version: edition.lock_version))
    button_text = options[:force] ? "Force Publish" : "Publish"
    button_title = "Publish #{edition.title}"
    confirm = publish_edition_alerts(edition, options[:force])
    css_classes = ["btn"]
    css_classes << (options[:force] ? "btn-warning" : "btn-success")
    button_to button_text, url, confirm: confirm, title: button_title, class: css_classes.join(" ")
  end

  def schedule_edition_form(edition, options = {})
    url = schedule_admin_edition_path(edition, options.slice(:force).merge(lock_version: edition.lock_version))
    button_text = options[:force] ? "Force Schedule" : "Schedule"
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
    button_to 'Unpublish', unpublish_admin_edition_path(edition, lock_version: edition.lock_version), title: "Unpublish", confirm: "Are you sure you want to unpublish the document?", class: "btn btn-danger"
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
