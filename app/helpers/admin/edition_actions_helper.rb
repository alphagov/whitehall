module Admin::EditionActionsHelper
  def edit_edition_button(edition)
    link_to 'Edit', edit_admin_edition_path(edition), title: "Edit #{edition.title}", class: "btn"
  end

  def redraft_edition_button(edition)
    button_to 'Create new edition', revise_admin_edition_path(edition), title: "Create new edition", class: "btn"
  end

  def most_recent_edition_button(edition)
    link_to "Go to most recent edition", admin_edition_path(edition.latest_edition),
            title: "Go to most recent edition of #{edition.title}", class: "btn"
  end

  def submit_edition_button(edition)
    button_to "Submit to 2nd pair of eyes", submit_admin_edition_path(edition, lock_version: edition.lock_version), class: "btn"
  end

  def reject_edition_button(edition)
    button_to "Reject", reject_admin_edition_path(edition, lock_version: edition.lock_version), class: "btn"
  end

  def publish_edition_form(edition, options = {})
    url = publish_admin_edition_path(edition, options.slice(:force).merge(lock_version: edition.lock_version))
    button_text = options[:force] ? "Force Publish" : "Publish"
    button_title = "Publish #{edition.title}"
    confirm = publish_edition_alerts(edition, options[:force])
    capture {
      if edition.change_note_required?
        concat content_tag(:section, class: "container") {
          concat content_tag(:h1, "Change note")
          concat content_tag(:p) {
            if edition.minor_change?
              concat content_tag(:em, "This is a minor change")
            elsif edition.change_note.blank?
              concat content_tag(:em, "None")
            else
              concat edition.change_note
            end
          }
        }
      end
      concat button_to button_text, url, confirm: confirm, title: button_title, class: "btn"
    }
  end

  def delete_edition_button(edition)
    button_to 'Delete', admin_edition_path(edition), method: :delete, title: "Delete", confirm: "Are you sure you want to delete the document?", class: "btn"
  end

  def show_or_add_consultation_response_button(consultation)
    if consultation.latest_consultation_response
      show_consultation_response_button(consultation)
    else
      add_consultation_response_button(consultation)
    end
  end

  def add_consultation_response_button(consultation)
    link_to 'Add response', new_admin_consultation_response_path(edition: {consultation_id: consultation}), title: "Add response", class: "btn"
  end

  def show_consultation_response_button(consultation)
    link_to 'Show response', admin_consultation_response_path(consultation.latest_consultation_response), title: "Show response", class: "btn"
  end

  private

  def publish_edition_alerts(edition, force)
    alerts = []
    alerts << "Are you sure you want to force publish this document?" if force
    if edition.has_supporting_pages?
      alerts << "Have you checked the #{edition.supporting_pages.count} supporting pages?"
    end
    alerts.join(" ")
  end
end
