module ContentObjectStore
  class Engine < ::Rails::Engine
    initializer "content_object_store.load_locale" do |app|
      app.config.i18n.load_path += Dir[File.join(root, "config", "locales", "**", "*.{rb,yml}")]
    end
  end
end
