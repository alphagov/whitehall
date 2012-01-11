class DocumentAttachment < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :document

  after_destroy :destroy_attachment_if_required

  private

  def destroy_attachment_if_required
    unless DocumentAttachment.where(attachment_id: attachment.id).any?
      attachment.destroy
    end
  end
end
