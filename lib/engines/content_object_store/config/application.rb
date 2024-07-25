module ContentObjectStore
  class Engine < ::Rails::Engine
    config.autoload_paths << Dir[File.join(root, "app", "forms", "**", "*.{rb}")]

    initializer "content_object_store.load_locale" do |app|
      app.config.i18n.load_path += Dir[File.join(root, "config", "locales", "**", "*.{rb,yml}")]
    end
  end
end
