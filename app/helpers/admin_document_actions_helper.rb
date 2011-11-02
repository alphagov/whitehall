module AdminDocumentActionsHelper
  def edit_document_button(document)
    link_to 'Edit', edit_admin_document_path(document), title: "Edit #{document.title}", class: "button"
  end

  def redraft_document_button(document)
    button_to 'Create new draft', revise_admin_document_path(document), title: "Create new draft"
  end

  def submit_document_button(document)
    capture do
      form_for [:admin, document], {url: submit_admin_document_path(document), method: :post} do |submit_form|
        concat(submit_form.submit "Submit to 2nd pair of eyes")
      end
    end
  end

  def publish_document_button(document)
    capture do
      form_for [:admin, document], {as: :document, url: admin_document_publishing_path(document), method: :post} do |form|
        concat(form.hidden_field :lock_version)
        submit_options = {title: "Publish #{document.title}"}
        if document.has_supporting_documents?
          submit_options[:confirm] = "Have you checked the #{document.supporting_documents.count} supporting documents?"
        end
        concat(form.submit "Publish", submit_options)
      end
    end
  end

  def delete_document_button(document)
    button_to 'Delete', admin_document_path(document), method: :delete, title: "Delete", confirm: "Are you sure you want to delete the document?"
  end
end