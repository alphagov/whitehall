require 'test_helper'

class RummagerDocumentPresenterTest < ActiveSupport::TestCase
  def rummager_result
    {
      "link" => "/government/news/quiddich-world-cup-2018",
      "title" => "Quiddich World Cup 2018",
      "description" => "The Quiddich World Cup 2018 will be...",
      "public_timestamp" => "2018-10-25T10:18:32Z",
      "display_type" => "News story",
      "format" => "news_article",
      "government_name" => "2015 Ministry of Magic",
      "is_historic" => true,
      "document_collections" => [
        {
          "title" => "Wizarding sports",
          "link" => "/government/collections/wizarding-sports"
        },
        {
          "title" => "Guidance for hosting wizarding competitions",
          "link" => "/government/collections/guidance-for-hosting-wizarding-competitions"
        },
      ],
      "organisations" => [
        {
          "acronym" => "DMGS",
        },
        {
          "acronym" => "MOM",
        }
      ],
      "operational_field" => "hogwarts"
    }
  end

  def presenter
    RummagerDocumentPresenter.new rummager_result
  end

  test "will provide access to document attributes required for Finders and Lists" do
    assert_equal rummager_result['title'], presenter.title
    assert_equal rummager_result['link'], presenter.link
    assert_equal rummager_result['format'], presenter.type
    assert_equal rummager_result['government_name'], presenter.government_name
    assert_equal rummager_result['is_historic'], presenter.historic?
  end

  test "will produce a humanized publication date required by Finders and Lists" do
    assert_equal presenter.publication_date, '25 October 2018'
  end

  test "will produce an html block containing a time tag and the publication date" do
    assert_equal presenter.display_date_microformat, '<time class="public_timestamp" datetime="2018-10-25T10:18:32+00:00">25 October 2018</time>'
  end

  test "will returns associated document collections" do
    expected_result = "Part of a collection: <a href=\"https://www.test.gov.uk/government/collections/wizarding-sports\">" +
      "Wizarding sports</a> and <a href=\"https://www.test.gov.uk/government/collections/guidance-for-hosting-wizarding-competitions\">" +
      "Guidance for hosting wizarding competitions</a>"
    assert_equal expected_result, presenter.publication_collections
  end

  test "will return acronyms for associated organisations" do
    expected_result = "DMGS and MOM"
    assert_equal expected_result, presenter.organisations
  end

  test "will return title for associated organisation if there is no acronym" do
    search_result = {
      "organisations" => [
        {
          "title" => "Department for Magical Games and Sports",
        }
      ]
    }

    assert_equal search_result["organisations"].first["title"], RummagerDocumentPresenter.new(search_result).organisations
  end

  test "will return formatted operational field" do
    expected_result = "Field of operation: <a href=\"https://www.test.gov.uk/government/fields-of-operation/hogwarts\">Hogwarts</a>"
    assert_equal expected_result, presenter.field_of_operation
  end

  test "will return underscored display_type from Rummager if present" do
    assert_equal "news_story", presenter.display_type_key
  end

  test "will return content_store_document_type if display_type is not present" do
    search_result = { "content_store_document_type" => "news_story" }
    assert_equal "news_story", RummagerDocumentPresenter.new(search_result).display_type_key
  end

  test "will return humanized display_type_key" do
    assert_equal "News story", presenter.display_type
  end
end
