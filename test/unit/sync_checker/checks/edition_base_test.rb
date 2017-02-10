require 'minitest/autorun'
require 'mocha/setup'
require 'active_support'
require 'active_support/json'
require 'active_support/core_ext'
require 'test_helper'

require_relative '../../../../lib/sync_checker/formats/edition_base'

module SyncChecker::Checks
  class EditionBaseCheckTest < ActiveSupport::TestCase
    def sync_check
      SyncChecker::Formats::EditionBase.new("")
    end

    def test_base_path_with_non_english_primary_locale
      edition = build(:world_location_news_article)
      edition.primary_locale = "fr"
      edition.save!

      expected_path = Whitehall::UrlMaker.new.public_document_path(edition)

      sync_check_path = sync_check.get_path(edition, "fr")

      assert_equal expected_path, sync_check_path
    end

    def test_base_path_with_english_primary_locale_and_a_translated_edition
      edition = build(:world_location_news_article)
      with_locale(:fr) { edition.title = "en-francais" }
      edition.primary_locale = "fr"
      edition.save!

      edition.translated_locales.each do |locale|
        expected_path = I18n.with_locale(locale) do
          Whitehall::UrlMaker.new.public_document_path(edition)
        end

        sync_check_path = sync_check.get_path(edition, locale)

        assert_equal expected_path, sync_check_path
      end
    end

    def test_base_path_cannot_end_with_dot_en
      edition = build(:world_location_news_article)
      with_locale(:fr) { edition.title = "en-francais" }
      edition.primary_locale = "fr"
      edition.save!

      edition.translated_locales.each do |locale|
        sync_check_path = sync_check.get_path(edition, locale)

        refute sync_check_path.ends_with?(".en")
      end
    end
  end
end
