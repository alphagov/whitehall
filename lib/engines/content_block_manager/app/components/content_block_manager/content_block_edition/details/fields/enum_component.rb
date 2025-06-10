class ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  def initialize(enum:, default: "", **args)
    @enum = enum
    @default = default
    super(**args)
  end

private

  def options
    [blank_option, @enum].flatten.compact.map do |item|
      {
        text: item,
        value: item,
        selected: selected?(item),
      }
    end
  end

  def error_message
    error_items&.first&.fetch(:text)
  end

  def selected?(item)
    item == (value.presence || @default)
  end

  def blank_option
    @default.empty? ? "" : nil
  end
end
