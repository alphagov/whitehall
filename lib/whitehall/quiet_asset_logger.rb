module Whitehall
  class QuietAssetLogger < Rails::Rack::Logger
    protected
    def before_dispatch(env)
      super unless %r{^/assets/}.match env['PATH_INFO']
    end
  end
end