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
  feature :editionable_worldwide_organisations, description: "Enables editionable worldwide organisations", default: false
  feature :govspeak_visual_editor, description: "Enables a visual editor for Govspeak fields", default: false
  feature :content_object_store, description: "Enables the object store for sharable content", default: Rails.env.development?
end
