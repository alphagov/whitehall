class ContentBlockManager::Shared::ContinueOrCancelButtonGroup < ViewComponent::Base
  def initialize(form_id:, content_block_edition:, button_text: "Save and continue")
    @button_text = button_text
    @form_id = form_id
    @content_block_edition = content_block_edition
  end

private

  attr_reader :button_text, :form_id, :content_block_edition

  def redirect_path
    if is_editing?
      helpers.content_block_manager.content_block_manager_content_block_document_path(content_block_edition.document)
    else
      helpers.content_block_manager.content_block_manager_content_block_documents_path
    end
  end

  def is_editing?
    content_block_edition.document.editions.count > 1
  end
end
