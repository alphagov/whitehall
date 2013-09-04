# == Schema Information
#
# Table name: fatality_notice_casualties
#
#  id                 :integer          not null, primary key
#  fatality_notice_id :integer
#  personal_details   :text
#

class FatalityNoticeCasualty < ActiveRecord::Base
  belongs_to :fatality_notice
  validates :personal_details, presence: true
end
