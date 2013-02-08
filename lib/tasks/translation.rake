$LOAD_PATH.unshift(File.expand_path("../.."), __FILE__)
require "whitehall/translation"

namespace :translation do
  task :export, [:directory, :base_locale, :target_locale] do |t, args|
    base_locale = Rails.root.join("config", "locales", args[:source_locale] + ".yml")
    target_locale_path = Rails.root.join("config", "locales", args[:target_locale] + ".yml")
    exporter = Whitehall::Translation::Exporter.new(args[:directory], base_locale, target_locale_path)
    exporter.export
  end

  namespace :export do
    task :all, [:directory] do |t, args|
      locales = Dir[Rails.root.join("config", "locales", "*.yml")]
      base_locale = Rails.root.join("config", "locales", "en.yml")
      target_locales = locales - [base_locale.to_s]
      target_locales.each do |target_locale_path|
        exporter = Whitehall::Translation::Exporter.new(args[:directory], base_locale, target_locale_path)
        exporter.export
      end
    end
  end

  task :import, [:locale, :path] do |t, args|
    importer = Whitehall::Translation::Importer.new(args[:locale], args[:path], Rails.root.join("config", "locales"))
    importer.import
  end

  namespace :import do
    task :all, [:directory] do |t, args|
      Dir[File.join(args[:directory], "*.csv")].each do |csv_path|
        locale = File.basename(csv_path, ".csv")
        importer = Whitehall::Translation::Importer.new(locale, csv_path, Rails.root.join("config", "locales"))
        importer.import
      end
    end
  end
end
