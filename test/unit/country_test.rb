require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  test 'should be invalid without a name' do
    country = build(:country, name: nil)
    refute country.valid?
  end

  test 'should set a slug from the country name' do
    country = create(:country, name: 'Costa Rica')
    assert_equal 'costa-rica', country.slug
  end

  test 'should not change the slug when the country name is changed' do
    country = create(:country, name: 'New Holland')
    country.update_attributes(name: 'Australia')
    assert_equal 'new-holland', country.slug
  end

  test 'should not be featured' do
    country = create(:country, name: 'Cascadia')
    refute country.featured?
  end

  test 'should be featured if name matches hard-coded list' do
    %w[ Spain USA Uganda ].each do |name|
      assert create(:country, name: name).featured?
    end
  end

  test 'should return featured countries' do
    %w[ Spain USA Uganda Cascadia Virginia ].each do |name|
      create(:country, name: name)
    end
    assert_equal 3, Country.featured.length
  end

  test 'should return hard-coded urls for featured countries' do
    spain = create(:country, name: 'Spain')
    assert_equal %w[ http://ukinspain.fco.gov.uk ], spain.urls

    uganda = create(:country, name: 'Uganda')
    assert_equal %w[ http://ukinuganda.fco.gov.uk http://www.dfid.gov.uk/Uganda ], uganda.urls

    usa = create(:country, name: 'USA')
    assert_equal %w[ http://ukinusa.fco.gov.uk ], usa.urls
  end

  test 'should return no urls for countries that are not featured.' do
    country = create(:country)
    assert_equal [], country.urls
  end

  test '#featured_news_articles should return news articles featured against this country' do
    country = create(:country)
    other_country = create(:country)

    news_a = create(:published_news_article)
    news_b = create(:published_news_article)
    news_c = create(:published_news_article)

    create(:document_country, country: country, edition: news_a, featured: true)
    create(:document_country, country: country, edition: news_b, featured: true)
    create(:document_country, country: other_country, edition: news_c, featured: true)

    assert_equal [news_a, news_b], country.featured_news_articles
  end

  test '#featured_news_articles should only return published articles' do
    country = create(:country)

    news_a = create(:published_news_article)
    news_b = create(:draft_news_article)

    create(:document_country, country: country, edition: news_a, featured: true)
    create(:document_country, country: country, edition: news_b, featured: true)

    assert_equal [news_a], country.featured_news_articles
  end

  test '#featured_news_articles should only return featured articles' do
    country = create(:country)

    news_a = create(:published_news_article)
    news_b = create(:published_news_article)

    create(:document_country, country: country, edition: news_a, featured: false)
    create(:document_country, country: country, edition: news_b, featured: true)

    assert_equal [news_b], country.featured_news_articles
  end
end
