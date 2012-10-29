require 'csv'

class Whitehall::Uploader::Csv
  attr_reader :row_class, :model_class

  def initialize(data, row_class, model_class, logger = Logger.new($stdout))
    @csv = CSV.new(data, headers: true)
    @row_class = row_class
    @model_class = model_class
    @logger = logger
  end

  def import_as(creator)
    @csv.each_with_index do |data_row, ix|
      row = row_class.new(data_row.to_hash, ix + 1, @logger)
      if DocumentSource.find_by_url(row.legacy_url)
        @logger.warn "Row #{ix + 2} '#{row.legacy_url}' has already been imported"
      else
        attributes = row.attributes.merge(creator: creator)
        model = model_class.new(attributes)
        if model.save
          DocumentSource.create!(document: model.document, url: row.legacy_url)
          row.cleanup
        else
          @logger.warn "Row #{ix + 2} '#{row.legacy_url}' couldn't be saved for the following reasons: #{model.errors.full_messages}"
        end
      end
    end
  end
end
