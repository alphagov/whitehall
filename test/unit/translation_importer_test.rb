require "fast_test_helper"
require "whitehall/translation/importer"
require "tmpdir"
require "csv"

class TranslationImporterTest < ActiveSupport::TestCase
  test 'should create a new locale file for a filled in translation csv file' do
    given_csv(:fr,
      ["world_location.type.country", "Country", "Pays"],
      ["world_location.country", "Germany", "Allemange"],
      ["other.nested.key", "original", "translated"]
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    yaml_translation_data = YAML.load_file(File.join(import_directory, "fr.yml"))
    expected = {"fr" => {
      "world_location" => {
        "country" => "Allemange",
        "type" => {
          "country" => "Pays"
        }
      },
      "other" => {
        "nested" => {
          "key" => "translated"
        }
      }
    }}
    assert_equal expected, yaml_translation_data
  end

  test 'outputs YAML without the header --- line for consistency with convention' do
    given_csv(:fr,
      ["key", "value", "le value"],
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    assert_equal "fr:", File.readlines(File.join(import_directory, "fr.yml")).first.strip
  end

  test 'outputs a newline at the end of the YAML for consistency with code editors' do
    given_csv(:fr,
      ["key", "value", "le value"],
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    assert_match /\n$/, File.readlines(File.join(import_directory, "fr.yml")).last
  end

  test 'strips whitespace from the end of lines for consistency with code editors' do
    given_csv(:fr,
      ["key", "value", nil],
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    lines = File.readlines(File.join(import_directory, "fr.yml"))
    refute lines.any? { |line| line =~ /\s\n$/ }
  end

  test 'imports arrays from CSV as arrays' do
    given_csv(:fr,
      ["fruit", %w(Apples Bananas Pears), %w(Pommes Bananes Poires)]
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    yaml_translation_data = YAML.load_file(File.join(import_directory, "fr.yml"))
    expected = {"fr" => {
      "fruit" => %w(Pommes Bananes Poires)
    }}
    assert_equal expected, yaml_translation_data
  end

  test 'interprets string "nil" as nil' do
    given_csv(:fr,
      ["things", ["one", nil, "two"], ["une", nil, "deux"]]
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    yaml_translation_data = YAML.load_file(File.join(import_directory, "fr.yml"))
    expected = {"fr" => {
      "things" => ["une", nil, "deux"]
    }}
    assert_equal expected, yaml_translation_data
  end

  test 'interprets string ":thing" as symbol' do
    given_csv(:fr,
      ["sentiment", ":whatever", ":bof"]
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    yaml_translation_data = YAML.load_file(File.join(import_directory, "fr.yml"))
    expected = {"fr" => {
      "sentiment" => :bof
    }}
    assert_equal expected, yaml_translation_data
  end

  test 'interprets integer strings as integers' do
    given_csv(:fr,
      %w(price 123 123)
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    yaml_translation_data = YAML.load_file(File.join(import_directory, "fr.yml"))
    expected = {"fr" => {
      "price" => 123
    }}
    assert_equal expected, yaml_translation_data
  end

  test 'interprets boolean values as booleans, not strings' do
    given_csv(:fr,
      ["key1", "is true", "true"],
      ["key2", "is false", "false"]
    )

    Whitehall::Translation::Importer.new(:fr, csv_path(:fr), import_directory).import

    yaml_translation_data = YAML.load_file(File.join(import_directory, "fr.yml"))
    expected = {"fr" => {
      "key1" => true,
      "key2" => false
    }}
    assert_equal expected, yaml_translation_data
  end

  private

  def csv_path(locale)
    File.join(import_directory, "#{locale}.csv")
  end

  def given_csv(locale, *rows)
    csv = CSV.generate do |csv|
      csv << CSV::Row.new(%w(key source translation), %w(key source translation), true)
      rows.each do |row|
        csv << CSV::Row.new(%w(key source translation), row)
      end
    end
    File.open(csv_path(locale), "w") { |f| f.write csv.to_s }
  end

  def import_directory
    @import_directory ||= Dir.mktmpdir
  end
end
