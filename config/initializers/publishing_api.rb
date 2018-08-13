require 'gds_api/publishing_api'

Whitehall.publishing_api_client = GdsApi::PublishingApi.new(
  Plek.find('publishing-api'),
  bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
)

require 'services'

Whitehall::PublishingApi::LogSubscriber.attach_to :publishing_api

ActiveSupport.on_load(:action_controller) do
  include Whitehall::PublishingApi::ControllerRuntime
end
