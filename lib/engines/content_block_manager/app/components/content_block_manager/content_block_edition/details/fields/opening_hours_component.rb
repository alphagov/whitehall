class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
  private

  def checked
    # TODO
  end

  def conditional

  end

  def items
    puts "here in items"
    [
      {
        label: "Hours available",
        value: "1",
        checked: false,
        conditional: capture do sanitize("<p>hello</p>") end,
      },
    ]
  end
end