require 'test_helper'

class TranslationsForAssociationsTest < ActiveSupport::TestCase
  test 'with_translations_for should eager load the association and it\'s translations' do
    dc = create(:ministerial_role, organisations: [create(:organisation)])

    eagerly_loaded = MinisterialRole.with_translations_for(:organisations).to_a.first

    query_count = count_queries { eagerly_loaded.organisations.first.name }
    assert_equal 0, query_count
  end
end
