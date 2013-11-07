require 'test_helper'

class VisualisationsHelperTest < ActionView::TestCase
  test "#horizontal_percent_bar should render a div in div with the inner one's width set to the passed in fraction as percent" do
    rendered = Nokogiri::HTML::DocumentFragment.parse(horizontal_percent_bar(0.3))
    assert_present rendered.at_css(".horizontal-percent-bar .bar-inner")
    assert rendered.at_css('.horizontal-percent-bar .bar-inner')[:style].include? "width: 30%"
  end
end
