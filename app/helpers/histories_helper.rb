module HistoriesHelper
  def meta_description(description)
    @meta_description = Govspeak::Document.new(description).to_text
  end
end
