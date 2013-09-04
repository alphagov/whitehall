# == Schema Information
#
# Table name: edition_attachments
#
#  id            :integer          not null, primary key
#  edition_id    :integer
#  attachment_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class EditionAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :edition
end
