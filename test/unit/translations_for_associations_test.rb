require 'test_helper'

class TranslationsForAssociationsTest < ActiveSupport::TestCase
  test 'with_translations_for should eager load the association and it\'s translations' do
    ds = create(:document_series, organisation: create(:organisation))

    eagerly_loaded = DocumentSeries.with_translations_for(:organisation).to_a.first

    query_count = count_queries { eagerly_loaded.organisation.name }
    assert_equal 0, query_count
  end
end
