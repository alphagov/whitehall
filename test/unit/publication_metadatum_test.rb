require "test_helper"

class PublicationMetadatumTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    metadatum = build(:publication_metadatum)
    assert metadatum.valid?
  end

  test 'should be invalid without a publication date' do
    metadatum = build(:publication_metadatum, publication_date: nil)
    refute metadatum.valid?
  end

  test 'should be valid without ISBN' do
    metadatum = build(:publication_metadatum, isbn: nil)
    assert metadatum.valid?
  end

  test 'should be valid with blank ISBN' do
    metadatum = build(:publication_metadatum, isbn: "")
    assert metadatum.valid?
  end

  test 'should be invalid with ISBN but not in ISBN-10 or ISBN-13 format' do
    metadatum = build(:publication_metadatum, isbn: "invalid-isbn")
    refute metadatum.valid?
  end

  test 'should be valid with ISBN in ISBN-10 format' do
    metadatum = build(:publication_metadatum, isbn: "0261102737")
    assert metadatum.valid?
  end

  test 'should be valid with ISBN in ISBN-13 format' do
    metadatum = build(:publication_metadatum, isbn: "978-0261103207")
    assert metadatum.valid?
  end

  test 'should be invalid with malformed order url' do
    metadatum = build(:publication_metadatum, order_url: "invalid-url")
    refute metadatum.valid?
  end

  test 'should be valid with order url with HTTP protocol' do
    metadatum = build(:publication_metadatum, order_url: "http://example.com")
    assert metadatum.valid?
  end

  test 'should be valid with order url with HTTPS protocol' do
    metadatum = build(:publication_metadatum, order_url: "https://example.com")
    assert metadatum.valid?
  end

  test 'should be valid without order url' do
    metadatum = build(:publication_metadatum, order_url: nil)
    assert metadatum.valid?
  end

  test 'should be valid with blank order url' do
    metadatum = build(:publication_metadatum, order_url: nil)
    assert metadatum.valid?
  end
end