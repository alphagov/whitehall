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
  feature :show_link_to_content_block_manager, description: "Shows link to Content Block Manager from Whitehall editor", default: Whitehall.integration_or_staging?
  feature :configurable_document_types,
          description: "Enable 'in development' config-driven document types (alongside the 'live' ones)",
          default: Rails.env.development?
  feature :mini_sites,
          description: "Enable Mini Site document types ('mini_site_landing' and 'mini_site_child')",
          default: Rails.env.development?
end
