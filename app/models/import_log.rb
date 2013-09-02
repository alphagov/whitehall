# == Schema Information
#
# Table name: import_logs
#
#  id         :integer          not null, primary key
#  import_id  :integer
#  row_number :integer
#  level      :string(255)
#  message    :text
#  created_at :datetime
#

class ImportLog < ActiveRecord::Base
  belongs_to :import
  default_scope order("id ASC")

  def to_s
    "Row #{row_number} - #{level}: #{message}"
  end
end
