module Whitehall

  mattr_accessor :host
  self.host = nil

  def self.domain
    uri = ['http://', host].join
    URI.parse(uri).host
  end

  class Railtie < Rails::Railtie
    config.whitehall = ActiveSupport::OrderedOptions.new

    initializer "whitehall.set_configs" do |app|
      app.config.whitehall.each do |k,v|
        Whitehall.send "#{k}=", v
      end
    end
  end
end