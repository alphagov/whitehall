Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :cookie
  strategy :active_record, hidden: !Rails.env.development?
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
  feature :maintenance_mode, description: "Put Whitehall into maintenance mode for planned downtime", default: false
  feature :override_government, description: "Enables GDS Editors and Admins to override the government associated with a document", default: false
  feature :show_link_to_content_block_manager, description: "Shows link to Content Block Manager from Whitehall editor", default: Whitehall.integration_or_staging?
  feature :show_all_content_block_types,
          description: "Show all applicable content block types in Content Block Manager",
          default: Whitehall.integration_or_staging? || !Rails.env.production?
  feature :use_friendly_embed_codes,
          description: "Use embed codes with friendly IDs in Content Block Manager",
          default: Whitehall.integration_or_staging? || !Rails.env.production?
  feature :configurable_document_types,
          description: "Enable config driven document types",
          default: Rails.env.development?
end
