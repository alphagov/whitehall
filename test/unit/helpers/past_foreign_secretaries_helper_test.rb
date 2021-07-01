require "test_helper"

class PastForeignSecretariesHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "returns past foreign secretaries navigation list" do
    html_string = past_foreign_secretary_nav("edward-wood")
    html = Nokogiri::HTML.fragment(html_string)

    all_people = (html / "li")
    people_with_links = (html / "li").select do |person|
      person.children.to_s =~ /href="\/government\/history\/past-foreign-secretaries\/.*/
    end

    assert_equal 9, people_with_links.count
    assert_equal 10, all_people.count
    assert people_with_links.map(&:text).include?("Sir Edward Grey")
    assert_not people_with_links.map(&:text).include?("Edward Frederick Lindley Wood")
  end
end
