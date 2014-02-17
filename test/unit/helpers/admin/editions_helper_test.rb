require "test_helper"

class Admin::EditionsHelperTest < ActionView::TestCase
  def govspeak_embedded_contacts(*args)
    []
  end

  test 'warn_about_lack_of_contacts_in_body? says no if the edition is not a news article' do
    (Edition.descendants - [NewsArticle] - NewsArticle.descendants).each do |not_a_news_article|
      refute warn_about_lack_of_contacts_in_body?(not_a_news_article.new)
    end
  end

  test 'warn_about_lack_of_contacts_in_body? says no if the edition is a news article, but is not a press release' do
    (NewsArticleType.all - [NewsArticleType::PressRelease]).each do |not_a_press_release|
      refute warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: not_a_press_release))
    end
  end

  test 'warn_about_lack_of_contacts_in_body? says no if the edition is a press release and it has at least one contact embedded in the body' do
    stubs(:govspeak_embedded_contacts).returns([build(:contact)])
    refute warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test 'warn_about_lack_of_contacts_in_body? says yes if the edition is a press release and it has at no contacts embedded in the body' do
    stubs(:govspeak_embedded_contacts).returns([])
    assert warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test 'default_edition_tabs includes document collection tab for a persisted document collection' do
    document_collection = build(:document_collection)
    refute_includes default_edition_tabs(document_collection).keys, "Collection documents"
    document_collection = create(:document_collection)
    assert_includes default_edition_tabs(document_collection).keys, "Collection documents"
  end

  test 'specialist_sector_options_for_select returns grouped options' do
    oil_and_gas = OpenStruct.new(
      slug: 'oil-and-gas',
      title: 'Oil and Gas',
      topics: [
        OpenStruct.new(slug: 'oil-and-gas/wells', title: 'Wells'),
        OpenStruct.new(slug: 'oil-and-gas/fields', title: 'Fields')
      ]
    )

    tax = OpenStruct.new(
      slug: 'tax',
      title: 'Tax',
      topics: [
        OpenStruct.new(slug: 'tax/income-tax', title: 'Income Tax'),
        OpenStruct.new(slug: 'tax/capital-gains-tax', title: 'Capital Gains Tax')
      ]
    )

    sectors = [oil_and_gas, tax]

    expected_options = [
      ['Oil and Gas', [['Oil and Gas: Wells', 'oil-and-gas/wells'],
                       ['Oil and Gas: Fields', 'oil-and-gas/fields']]],
      ['Tax', [['Tax: Income Tax', 'tax/income-tax'],
               ['Tax: Capital Gains Tax', 'tax/capital-gains-tax']]]
    ]

    assert_equal expected_options, specialist_sector_options_for_select(sectors)
  end

  test 'specialist_sector_fields should pass a list of sectors into a block' do
    SpecialistSector.stubs(:grouped_sector_topics).returns(:sector_list)

    response = specialist_sector_fields do |sectors|
      assert_equal :sector_list, sectors
      'Some string'
    end

    assert_equal 'Some string', response
  end

  test 'specialist_sector_fields should return nothing when the list of sectors is unavailable' do
    SpecialistSector.stubs(:grouped_sector_topics)
                    .raises(SpecialistSector::DataUnavailable.new)

    response = specialist_sector_fields do |sectors|
      assert false, 'Block should not be called'
      'Some string'
    end

    assert_equal nil, response
  end
end
