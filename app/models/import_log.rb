class ImportLog < ActiveRecord::Base
  belongs_to :import

  def to_s
    "Row #{row_number} - #{level}: #{message}"
  end
end
