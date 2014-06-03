require "fast_test_helper"
require "whitehall/translation/exporter"
require "tmpdir"
require "csv"
require 'i18n'
require 'active_support/core_ext/hash'

class TranslationExporterTest < ActiveSupport::TestCase
  setup do
    # fast test helper means we have to setup the pluralizations we're
    # going to use manually as rails-i18n does it in the rails app
    I18n.backend.class.send(:include, I18n::Backend::Pluralization)
    with_pluralization_forms(
      'fr' => [:one, :other],
      'es' => [:one, :other],
      'ar' => [:zero, :one, :two, :few, :many, :other],
      'sk' => [:one, :few, :other],
      'uk' => [:one, :few, :many, :other]
    )
  end

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
    assert_equal %w(Country Pays), data["world_location.type.country"]
    assert_equal %w(Spain Espange), data["world_location.country"]
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

  test 'should export correct pluralization forms for target' do
    given_locale(:en, {
      ministers: {
        one: 'minister',
        other: 'ministers'
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:ar)).export

    assert File.file?(exported_file("ar.csv")), "should write a file"

    data = read_csv_data(exported_file("ar.csv"))
    %w(zero one two few many other).each do |arabic_plural_form|
      assert data.has_key?("ministers.#{arabic_plural_form}"), "expected plural form #{arabic_plural_form} to be present, but it's not"
    end
  end

  test 'should export source pluralization forms values to target when the forms match' do
    given_locale(:en, {
      ministers: {
        one: 'minister',
        other: 'ministers'
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:sk)).export

    assert File.file?(exported_file("sk.csv")), "should write a file"

    data = read_csv_data(exported_file("sk.csv"))
    assert_equal ['minister', nil], data['ministers.one']
    assert_equal ['ministers', nil], data['ministers.other']
    assert_equal [nil, nil], data['ministers.few']
  end

  test 'should keep existing target pluralization form values' do
    given_locale(:en, {
      ministers: {
        one: 'minister',
        other: 'ministers'
      }
    })
    given_locale(:sk, {
      ministers: {
        one: 'min',
        few: 'mini'
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:sk)).export

    assert File.file?(exported_file("sk.csv")), "should write a file"

    data = read_csv_data(exported_file("sk.csv"))
    assert_equal %w(minister min), data['ministers.one']
    assert_equal ['ministers', nil], data['ministers.other']
    assert_equal [nil, 'mini'], data['ministers.few']
  end

  test 'should allow for zero keys when detecting pluralization forms' do
    given_locale(:en, {
      ministers: {
        zero: 'no ministers',
        one: 'minister',
        other: 'ministers'
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:uk)).export

    assert File.file?(exported_file("uk.csv")), "should write a file"

    data = read_csv_data(exported_file("uk.csv"))
    %w(one few many other).each do |ukranian_plural_form|
      assert data.has_key?("ministers.#{ukranian_plural_form}"), "expected plural form #{ukranian_plural_form} to be present, but it's not"
    end
  end

  test 'should leave keys alone if the hash doesn\'t look like it only contains pluralization forms' do
    given_locale(:en, {
      ministers: {
        one: 'minister',
        other: 'ministers',
        monkey: 'monkey'
      }
    })

    Whitehall::Translation::Exporter.new(export_directory, locale_path(:en), locale_path(:uk)).export

    assert File.file?(exported_file("uk.csv")), "should write a file"

    data = read_csv_data(exported_file("uk.csv"))
    %w(few many).each do |ukranian_plural_form|
      refute data.has_key?("ministers.#{ukranian_plural_form}"), "expected plural form #{ukranian_plural_form} to be missing, but it's present"
    end
    %w(one other monkey).each do |non_plural_forms|
      assert data.has_key?("ministers.#{non_plural_forms}"), "expected non-plural form #{non_plural_forms} to be present, but it's not"
    end
  end
  private

  def read_csv_data(file)
    csv = CSV.read(file, headers: true)
    csv.reduce({}) { |h, row| h[row["key"]] = [row["source"], row["translation"]]; h }
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

  def with_pluralization_forms(pluralizations)
    pluralizations.each do |locale, pluralization_forms|
      I18n.backend.store_translations(locale, {
        'i18n' => {
          'plural' => {
            'keys' => pluralization_forms
          }
        }
      })
    end
  end
end
