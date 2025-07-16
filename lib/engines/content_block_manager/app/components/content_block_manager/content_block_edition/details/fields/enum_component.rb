class ContentBlockManager::ContentBlockEdition::Details::Fields::EnumComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  def initialize(enum:, default: "", **args)
    @enum = enum
    @default = default
    super(**args)
  end

  def options
    options = [
      {
        text: blank_option,
        value: "",
        selected: selected?(blank_option),
      },
    ]

    enum.each do |item|
      options.push({
        text: item,
        value: item,
        selected: selected?(item),
      })
    end

    options
  end

private

  attr_reader :enum

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
