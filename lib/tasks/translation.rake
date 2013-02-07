namespace :translation do
  task :export, [:directory,:source_locale,:target_locale] do |t, args|
    $LOAD_PATH.unshift(File.expand_path("../.."), __FILE__)
    require "whitehall/translation"
    source_locale_path = Rails.root.join("config", "locales", args[:source_locale] + ".yml")
    target_locale_path = Rails.root.join("config", "locales", args[:target_locale] + ".yml")
    exporter = Whitehall::Translation::Exporter.new(args[:directory], source_locale_path, target_locale_path)
    exporter.export
  end
end
