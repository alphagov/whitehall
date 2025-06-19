class ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
private

  def heading
    "#{label}?"
  end

  def items
    [
      {
        value: true,
        text: "Yes",
        checked: value.present? ? ActiveModel::Type::Boolean.new.cast(value) : false,
      },
      {
        value: false,
        text: "No",
        checked: value.present? ? !ActiveModel::Type::Boolean.new.cast(value) : false,
      },
    ]
  end
end
