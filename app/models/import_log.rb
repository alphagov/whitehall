class ImportLog < ActiveRecord::Base
  belongs_to :import
  default_scope order("import_id, row_number")

  def to_s
    "Row #{row_number} - #{level}: #{message}"
  end
end