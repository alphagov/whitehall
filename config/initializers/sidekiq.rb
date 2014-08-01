redis_config = YAML.load_file(Rails.root.join("config", "redis.yml")).symbolize_keys

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.error_handlers << Proc.new {|ex, context_hash| Airbrake.notify(ex, context_hash) }
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# make sidekiq web responses bypass slimmer
require 'sidekiq/web'
module Sidekiq
  class Web < Sinatra::Base

    def erb_with_skip_slimmer_header(*args)
      headers("X-Slimmer-Skip" => 1)
      erb_without_skip_slimmer_header(*args)
    end
    alias_method_chain :erb, :skip_slimmer_header

  end
end
