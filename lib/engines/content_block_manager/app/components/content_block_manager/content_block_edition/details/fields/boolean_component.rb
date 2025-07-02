class ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent
private

  def items
    [
      {
        value: true,
        label:,
        checked: value.present? ? ActiveModel::Type::Boolean.new.cast(value) : false,
      },
    ]
  end
end
