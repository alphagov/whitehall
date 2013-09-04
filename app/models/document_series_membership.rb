# == Schema Information
#
# Table name: document_series_memberships
#
#  id                 :integer          not null, primary key
#  document_series_id :integer
#  document_id        :integer
#  ordering           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class DocumentSeriesMembership < ActiveRecord::Base
  belongs_to :document_series
  belongs_to :document
end
