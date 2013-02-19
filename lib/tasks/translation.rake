$LOAD_PATH.unshift(File.expand_path("../.."), __FILE__)
require "whitehall/translation"

namespace :translation do

  desc "Regenerate all locales from the EN locale - run this after adding keys"
  task :regenerate, [:directory] do |t, args|
    directory = args[:directory] || "tmp/locale_csv"
    Rake::Task["translation:export:all"].invoke(directory)
    Rake::Task["translation:import:all"].invoke(directory)
  end

  desc "Export a specific locale to CSV."
  task :export, [:directory, :base_locale, :target_locale] do |t, args|
    FileUtils.mkdir_p(args[:directory]) unless File.exist?(args[:directory])
    base_locale = Rails.root.join("config", "locales", args[:source_locale] + ".yml")
    target_locale_path = Rails.root.join("config", "locales", args[:target_locale] + ".yml")
    exporter = Whitehall::Translation::Exporter.new(args[:directory], base_locale, target_locale_path)
    exporter.export
  end

  namespace :export do
    desc "Export all locales to CSV files."
    task :all, [:directory] do |t, args|
      directory = args[:directory] || "tmp/locale_csv"
      FileUtils.mkdir_p(directory) unless File.exist?(args[:directory])
      locales = Dir[Rails.root.join("config", "locales", "*.yml")]
      base_locale = Rails.root.join("config", "locales", "en.yml")
      target_locales = locales - [base_locale.to_s]
      target_locales.each do |target_locale_path|
        exporter = Whitehall::Translation::Exporter.new(directory, base_locale, target_locale_path)
        exporter.export
      end
      puts "Exported locale CSV to #{directory}"
    end
  end

  desc "Import a specific locale CSV to YAML within the app."
  task :import, [:locale, :path] do |t, args|
    importer = Whitehall::Translation::Importer.new(args[:locale], args[:path], Rails.root.join("config", "locales"))
    importer.import
  end

  namespace :import do
    desc "Import all locale CSV files to YAML within the app."
    task :all, [:directory] do |t, args|
      directory = args[:directory] || "tmp/locale_csv"
      Dir[File.join(directory, "*.csv")].each do |csv_path|
        locale = File.basename(csv_path, ".csv")
        importer = Whitehall::Translation::Importer.new(locale, csv_path, Rails.root.join("config", "locales"))
        importer.import
      end
    end
  end
end
