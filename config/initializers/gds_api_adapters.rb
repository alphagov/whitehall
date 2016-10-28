GdsApi.configure do |config|
  # Opt out of always returning hashes for `GdsApi::Response`s
  config.hash_response_for_requests = false
end
