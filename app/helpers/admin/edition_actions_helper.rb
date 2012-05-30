module Admin::EditionActionsHelper
  def edit_edition_button(edition)
    link_to 'Edit', edit_admin_document_path(edition), title: "Edit #{edition.title}", class: "button"
  end

  def redraft_edition_button(edition)
    button_to 'Create new edition', revise_admin_edition_path(edition), title: "Create new edition"
  end

  def most_recent_edition_button(edition)
    link_to "Go to most recent edition", admin_document_path(edition.latest_edition),
            title: "Go to most recent edition of #{edition.title}", class: "button"
  end

  def submit_edition_button(edition)
    capture do
      form_for [:admin, edition], {url: submit_admin_edition_path(edition, lock_version: edition.lock_version), method: :post} do |submit_form|
        concat(submit_form.submit "Submit to 2nd pair of eyes")
      end
    end
  end

  def reject_edition_button(edition)
    capture do
      form_for [:admin, edition], {url: reject_admin_edition_path(edition, lock_version: edition.lock_version), method: :post} do |reject_form|
        concat(reject_form.submit "Reject")
      end
    end
  end

  def publish_edition_form(edition, options = {})
    url = publish_admin_edition_path(edition, options.slice(:force).merge(lock_version: edition.lock_version))
    button_text = options[:force] ? "Force Publish" : "Publish"
    button_title = "Publish #{edition.title}"
    confirm = publish_edition_alerts(edition, options[:force])
    capture do
      form_for [:admin, edition], {as: :edition, url: url, method: :post, html: {id: "edition_publishing"}} do |form|
        concat(form.hidden_field :lock_version)
        if edition.change_note_required?
          concat(form.text_area :change_note, label_text: "Change note (will appear on public site)", rows: 4)
          concat(form.check_box :minor_change, label_text: "Minor change?")
          concat(content_tag :div, "(for typos and other minor corrections, nothing will appear on public site)", class: 'for_checkbox hint')
        end
        concat(form.submit button_text, title: button_title, confirm: confirm)
      end
    end
  end

  def delete_edition_button(edition)
    button_to 'Delete', admin_document_path(edition), method: :delete, title: "Delete", confirm: "Are you sure you want to delete the document?"
  end

  def show_or_add_consultation_response_button(consultation)
    if consultation.latest_consultation_response
      show_consultation_response_button(consultation)
    else
      add_consultation_response_button(consultation)
    end
  end

  def add_consultation_response_button(consultation)
    link_to 'Add response', new_admin_consultation_response_path(edition: {consultation_id: consultation}), title: "Add response", class: "button"
  end

  def show_consultation_response_button(consultation)
    link_to 'Show response', admin_consultation_response_path(consultation.latest_consultation_response), title: "Show response", class: "button"
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