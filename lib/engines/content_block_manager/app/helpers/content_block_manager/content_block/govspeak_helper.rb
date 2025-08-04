module ContentBlockManager::ContentBlock::GovspeakHelper
  include ContentBlockTools::Govspeak

  def render_govspeak_if_enabled_for_field(object_key:, field_name:, value:)
    return value unless field_enabled_for_govspeak?(object_key, field_name)

    render_govspeak(value)
  end

  def field_enabled_for_govspeak?(object_key, field_name)
    subschema.govspeak_enabled?(nested_object_key: object_key, field_name: field_name)
  end
end
