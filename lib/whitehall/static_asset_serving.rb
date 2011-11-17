require "rack/directory"

class Whitehall::StaticAssetServing
  def initialize(app, url_path, asset_path)
    @app = app
    @path_regexp = Regexp.new(Regexp.escape(url_path))
    @asset_app = Rack::Directory.new(File.expand_path(asset_path))
  end
  def call(env)
    if env["PATH_INFO"] =~ @path_regexp
      env["PATH_INFO"] = env["PATH_INFO"].gsub(@path_regexp, "")
      p "loading from asset app"
      @asset_app.call(env)
    else
      @app.call(env)
    end
  end
end