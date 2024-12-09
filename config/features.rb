Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :active_record, hidden: !Rails.env.development?
  strategy :cookie
  strategy :default

  # Other strategies:
  #
  # strategy :sequel
  # strategy :redis
  #
  # strategy :query_string
  # strategy :session
  #
  # strategy :my_strategy do |feature|
  #   # ... your custom code here; return true/false/nil.
  # end

  # Declare your features, e.g:
  #
  # feature :world_domination,
  #   default: true,
  #   description: "Take over the world."
  feature :govspeak_visual_editor, description: "Enables a visual editor for Govspeak fields", default: false
  feature :override_government, description: "Enables GDS Editors and Admins to override the government associated with a document", default: false
  feature :show_link_to_content_block_manager, description: "Shows link to Content Block Manager from Whitehall editor", default: Whitehall.integration_or_staging?
  feature :editionable_topical_events, description: "Enables edtionable topical events", default: false
end
