class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
private

  def checked
    # TODO
  end

  def items
    [
      {
        label: "Hours available",
        value: "1",
        checked: true,
        conditional:,
      },
    ]
  end

  def conditional
    render(ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::DaysComponent.new)
  end
end
