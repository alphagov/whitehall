require "fast_test_helper"
require "whitehall/translation/exporter"
require "tmpdir"
require "csv"

class TranslationExporterTest < ActiveSupport::TestCase
  test 'should export CSV file for filling in a given translation' do
    given_locale(:en, {
      world_location: {
        type: {
          country: "Country"
        },
        country: "Spain",
        headings: {
          mission: "Our mission",
          offices: "Offices"
        }
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:fr)).export

    assert File.file?(exported_file("fr.csv")), "should write a file"

    data = read_csv_data(exported_file("fr.csv"))
    assert_equal ["Country", nil], data["world_location.type.country"]
    assert_equal ["Spain", nil], data["world_location.country"]
    assert_equal ["Our mission", nil], data["world_location.headings.mission"]
    assert_equal ["Offices", nil], data["world_location.headings.offices"]
  end

  test 'should include any existing translations in the output file' do
    given_locale(:en, {
      world_location: {
        type: {
          country: "Country"
        },
        country: "Spain",
        headings: {
          mission: "Our mission",
          offices: "Offices"
        }
      }
    })
    given_locale(:fr, {
      world_location: {
        type: {
          country: "Pays"
        },
        country: "Espange"
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:fr)).export

    assert File.file?(exported_file("fr.csv")), "should write a file"

    data = read_csv_data(exported_file("fr.csv"))
    assert_equal ["Country", "Pays"], data["world_location.type.country"]
    assert_equal ["Spain", "Espange"], data["world_location.country"]
    assert_equal ["Our mission", nil], data["world_location.headings.mission"]
    assert_equal ["Offices", nil], data["world_location.headings.offices"]
  end

  test 'should not include any language names that are not English or the native in the output file' do
    given_locale(:en, {
      language_names: {
        en: "English",
        es: "Spanish",
        fr: "French"
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:fr)).export

    assert File.file?(exported_file("fr.csv")), "should write a file"

    data = read_csv_data(exported_file("fr.csv"))
    assert_equal ["French", nil], data["language_names.fr"]
    assert_equal nil, data["language_names.es"], "language key for spanish should not be present"
  end

  private

  def read_csv_data(file)
    csv = CSV.read(file, headers: true)
    csv.inject({}) { |h, row| h[row["key"]] = [row["source"],row["translation"]]; h }
  end

  def given_locale(locale, keys)
    File.open(locale_path(locale), "w") do |f|
      f.puts({locale => keys}.to_yaml)
    end
  end

  def locale_path(locale)
    File.join(export_directory, "#{locale}.yml")
  end

  def exported_file(name)
    File.new(File.join(export_directory, name))
  end

  def export_directory
    @tmpdir ||= Dir.mktmpdir
  end
end
