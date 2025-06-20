class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHours::DaysComponent < ViewComponent::Base
private

  def options
    [
      {
        text: "Monday",
        value: "Monday",
      },
      {
        text: "Tuesday",
        value: "Tuesday",
      },
    ]
  end
end
