# == Schema Information
#
# Table name: attachment_sources
#
#  id            :integer          not null, primary key
#  attachment_id :integer
#  url           :string(255)
#

class AttachmentSource < ActiveRecord::Base
  belongs_to :attachment
end
