class ImportLog < ActiveRecord::Base
  belongs_to :import
  default_scope order("id ASC")

  def to_s
    "Row #{row_number} - #{level}: #{message}"
  end
end