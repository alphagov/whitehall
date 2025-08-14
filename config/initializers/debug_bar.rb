return unless (defined? Debugbar) && Rails.env.development?

Debugbar.configure do |config|
  config.enabled = true
end
