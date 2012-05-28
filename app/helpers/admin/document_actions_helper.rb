module Admin::DocumentActionsHelper
  def edit_document_button(document)
    link_to 'Edit', edit_admin_document_path(document), title: "Edit #{document.title}", class: "button"
  end

  def redraft_document_button(document)
    button_to 'Create new edition', revise_admin_document_path(document), title: "Create new edition"
  end

  def most_recent_edition_button(document)
    link_to "Go to most recent edition", admin_document_path(document.latest_edition),
            title: "Go to most recent edition of #{document.title}", class: "button"
  end

  def submit_document_button(document)
    capture do
      form_for [:admin, document], {url: submit_admin_document_path(document), method: :post} do |submit_form|
        concat(submit_form.submit "Submit to 2nd pair of eyes")
      end
    end
  end

  def reject_document_button(document)
    capture do
      form_for [:admin, document], {url: reject_admin_document_path(document), method: :post} do |reject_form|
        concat(reject_form.submit "Reject")
      end
    end
  end

  def publish_document_form(document, options = {})
    url = admin_document_publishing_path(document, options.slice(:force))
    button_text = options[:force] ? "Force Publish" : "Publish"
    button_title = "Publish #{document.title}"
    confirm = publish_document_alerts(document, options[:force])
    capture do
      form_for [:admin, document], {as: :document, url: url, method: :post, html: {id: "document_publishing"}} do |form|
        concat(form.hidden_field :lock_version)
        if document.change_note_required?
          concat(form.text_area :change_note, label_text: "Change note (will appear on public site)", rows: 4)
          concat(form.check_box :minor_change, label_text: "Minor change?")
          concat(content_tag :div, "(for typos and other minor corrections, nothing will appear on public site)", class: 'for_checkbox hint')
        end
        concat(form.submit button_text, title: button_title, confirm: confirm)
      end
    end
  end

  def delete_document_button(document)
    button_to 'Delete', admin_document_path(document), method: :delete, title: "Delete", confirm: "Are you sure you want to delete the document?"
  end

  def show_or_add_consultation_response_button(consultation)
    if consultation.latest_consultation_response
      show_consultation_response_button(consultation)
    else
      add_consultation_response_button(consultation)
    end
  end

  def add_consultation_response_button(consultation)
    link_to 'Add response', new_admin_consultation_response_path(document: {consultation_id: consultation}), title: "Add response", class: "button"
  end

  def show_consultation_response_button(consultation)
    link_to 'Show response', admin_consultation_response_path(consultation.latest_consultation_response), title: "Show response", class: "button"
  end

  private

  def publish_document_alerts(document, force)
    alerts = []
    alerts << "Are you sure you want to force publish this document?" if force
    if document.has_supporting_pages?
      alerts << "Have you checked the #{document.supporting_pages.count} supporting pages?"
    end
    alerts.join(" ")
  end
end