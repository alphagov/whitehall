# == Schema Information
#
# Table name: supporting_page_attachments
#
#  id                 :integer          not null, primary key
#  supporting_page_id :integer
#  attachment_id      :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class SupportingPageAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :supporting_page
end
