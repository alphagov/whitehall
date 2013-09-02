# == Schema Information
#
# Table name: document_sources
#
#  id          :integer          not null, primary key
#  document_id :integer
#  url         :string(255)      not null
#  import_id   :integer
#  row_number  :integer
#  locale      :string(255)      default("en")
#

class DocumentSource < ActiveRecord::Base
  belongs_to :document
  belongs_to :import

  validates :url, presence: true, uniqueness: true, uri: true
end
