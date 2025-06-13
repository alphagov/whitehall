# Load the flexible page schemas when the Rails application boots
Rails.application.config.after_initialize do
  FlexiblePageType.boot
end