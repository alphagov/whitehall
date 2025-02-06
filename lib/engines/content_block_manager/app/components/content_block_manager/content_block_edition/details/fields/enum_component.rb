class ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  def initialize(enum:, **args)
    @enum = enum
    super(**args)
  end

private

  def options
    ["", @enum].flatten.map do |item|
      {
        text: item.humanize,
        value: item,
        selected: item == value,
      }
    end
  end

  def error_message
    error_items&.first&.fetch(:text)
  end
end
