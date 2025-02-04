class ContentBlockManager::Shared::ContinueOrCancelButtonGroup < ViewComponent::Base
  def initialize(form_id:, content_block_edition:, button_text: "Save and continue")
    @button_text = button_text
    @form_id = form_id
    @content_block_edition = content_block_edition
  end

private

  attr_reader :button_text, :form_id, :content_block_edition

  def is_editing?
    content_block_edition.document.editions.count > 1
  end
end
