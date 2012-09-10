class CorporateInformationPageAttachment < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :corporate_information_page

  after_destroy :destroy_attachment_if_required

  accepts_nested_attributes_for :attachment, reject_if: :all_blank

  private

  def destroy_attachment_if_required
    unless CorporateInformationPageAttachment.where(attachment_id: attachment.id).any?
      attachment.destroy
    end
  end
end
