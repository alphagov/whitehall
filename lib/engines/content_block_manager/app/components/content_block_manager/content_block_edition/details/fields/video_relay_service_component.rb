class ContentBlockManager::ContentBlockEdition::Details::Fields::VideoRelayServiceComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::ObjectComponent
  def show_video_relay_service
    field.nested_field("show")
  end

  def prefix
    field.nested_field("prefix")
  end

  def telephone_number
    field.nested_field("telephone_number")
  end
end
