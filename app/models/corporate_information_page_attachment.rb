# == Schema Information
#
# Table name: corporate_information_page_attachments
#
#  id                            :integer          not null, primary key
#  corporate_information_page_id :integer
#  attachment_id                 :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#

class CorporateInformationPageAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :corporate_information_page
end
