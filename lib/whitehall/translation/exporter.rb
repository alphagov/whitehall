# encoding: utf-8
require "whitehall/translation"
require "yaml"

class Whitehall::Translation::Exporter
  def initialize(directory, source_locale_path, target_locale_path)
    @source_locale_path = source_locale_path
    @target_locale_path = target_locale_path
    @locale = File.basename(target_locale_path).split(".")[0]
    @output_path = File.join(directory, @locale + ".csv")

    @keyed_source_data = translation_file_to_keyed_data(source_locale_path)
    @keyed_target_data = translation_file_to_keyed_data(target_locale_path)
  end

  def export
    csv = CSV.generate do |csv|
      csv << CSV::Row.new(["key", "source", "translation"], ["key", "source", "translation"], true)
      @keyed_source_data.keys.sort.each do |key|
        if key =~ /^language_names\./
          next unless key =~ /#{@locale}$/
        end
        csv << CSV::Row.new(["key", "source", "translation"], [key, @keyed_source_data[key], @keyed_target_data[key]])
      end
    end
    File.open(@output_path, "w") { |f| f.write csv.to_s }
  end

  private

  def translation_file_to_keyed_data(path)
    if File.exist?(path)
      hash = YAML.load_file(path).values[0]
      hash_to_keyed_data("", hash)
    else
      {}
    end
  end

  def hash_to_keyed_data(prefix, hash)
    results = {}
    hash.each do |key, value|
      if value.is_a?(Hash)
        results.merge!(hash_to_keyed_data(key_for(prefix, key), value))
      else
        results[key_for(prefix, key)] = value
      end
    end
    results
  end

  def key_for(prefix, key)
    prefix.blank? ? key.to_s : "#{prefix}.#{key}"
  end
end
