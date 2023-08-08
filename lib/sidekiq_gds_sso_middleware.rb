require "sidekiq/web"

class SidekiqGdsSsoMiddleware
  SIDEKIQ_SIGNON_PERMISSION = "Sidekiq Admin".freeze

  def self.call(...) = new(...).call

  def initialize(env)
    @env = env
    @warden = env.fetch("warden")
  end

  def call
    status, headers, body = authenticated_sidekiq_request

    [status, headers, body]
  end

private

  attr_reader :env, :warden

  def authenticated_sidekiq_request
    warden.authenticate! if !warden.authenticated? || warden.user.remotely_signed_out?

    if warden.user.has_permission?(SIDEKIQ_SIGNON_PERMISSION)
      Sidekiq::Web.call(env)
    else
      [403, {}, ["Forbidden - access requires the \"#{SIDEKIQ_SIGNON_PERMISSION}\" permission"]]
    end
  end
end
