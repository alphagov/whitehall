# == Schema Information
#
# Table name: edition_document_series
#
#  id                 :integer          not null, primary key
#  edition_id         :integer          not null
#  document_series_id :integer          not null
#

class EditionDocumentSeries < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document_series

  validates_uniqueness_of :edition_id, scope: :document_series_id
end
