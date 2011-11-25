require "test_helper"

class PublicationMetadatumTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    publication = build(:publication)
    assert publication.valid?
  end

  test 'should be invalid without a publication date' do
    publication = build(:publication, publication_date: nil)
    refute publication.valid?
  end

  test 'should be valid without ISBN' do
    publication = build(:publication, isbn: nil)
    assert publication.valid?
  end

  test 'should be valid with blank ISBN' do
    publication = build(:publication, isbn: "")
    assert publication.valid?
  end

  test 'should be invalid with ISBN but not in ISBN-10 or ISBN-13 format' do
    publication = build(:publication, isbn: "invalid-isbn")
    refute publication.valid?
  end

  test 'should be valid with ISBN in ISBN-10 format' do
    publication = build(:publication, isbn: "0261102737")
    assert publication.valid?
  end

  test 'should be valid with ISBN in ISBN-13 format' do
    publication = build(:publication, isbn: "978-0261103207")
    assert publication.valid?
  end

  test 'should be invalid with malformed order url' do
    publication = build(:publication, order_url: "invalid-url")
    refute publication.valid?
  end

  test 'should be valid with order url with HTTP protocol' do
    publication = build(:publication, order_url: "http://example.com")
    assert publication.valid?
  end

  test 'should be valid with order url with HTTPS protocol' do
    publication = build(:publication, order_url: "https://example.com")
    assert publication.valid?
  end

  test 'should be valid without order url' do
    publication = build(:publication, order_url: nil)
    assert publication.valid?
  end

  test 'should be valid with blank order url' do
    publication = build(:publication, order_url: nil)
    assert publication.valid?
  end
end