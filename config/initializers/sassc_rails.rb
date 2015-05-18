# As recommended in https://github.com/bolandrm/sassc-rails/issues/6#issuecomment-100949872
require "sprockets/engines"

module Extensions
  module Sprockets
    module Engines
      def register_engine(ext, klass)
        return if [
          Sass::Rails::SassTemplate,
          Sass::Rails::ScssTemplate
        ].include?(klass)

        super
      end
    end
  end
end

Sprockets::Base.send(:prepend, Extensions::Sprockets::Engines)

Rails.application.assets.register_engine '.sass', SassC::Rails::SassTemplate
Rails.application.assets.register_engine '.scss', SassC::Rails::ScssTemplate
