require 'test_helper'

class PromotionalFeatureItemPresenterTest < ActionView::TestCase
  setup do
    ac = ApplicationController.new
    ac.set_current_view_context
    @view_context = ac.view_context
  end

  test '#css_classes returns "large" for double-width items' do
    assert_equal 'feature', item_presenter.css_classes
    assert_equal 'feature large', item_presenter(double_width: true).css_classes
  end

  test '#image_url returns 300px width images for single-width items' do
    item = item_presenter
    assert_equal item.image.s300.url, item.image_url
  end

  test '#image_url returns 630px width image path for double-width items' do
    item = item_presenter(double_width: true)
    assert_equal item.image.s630.url, item.image_url
  end

  test '#display_image returns a normal image tag if no link' do
    item = item_presenter
    assert_dom_equal %(<img alt="#{item.image_alt_text}" src="#{item.image_url}" />), item.display_image
  end

  test '#display_image returns a link if there is one' do
    item = item_presenter(title_url: 'http://external.com')
    assert_dom_equal %(<a href="http://external.com"><img alt="#{item.image_alt_text}" src="#{item.image_url}" /></a>), item.display_image
  end

  test '#link_list_class returns "dash-list" for single-width items' do
    assert_equal "dash-list", item_presenter.link_list_class
    assert_nil item_presenter(double_width: true).link_list_class
  end

  test '#width returns the width as an integer' do
    assert_equal 1, item_presenter.width
    assert_equal 2, item_presenter(double_width: true).width
  end

  test '#title returns nil if feature item has no title' do
    assert_nil item_presenter(title: nil).title
    assert_nil item_presenter(title: '').title
  end

  test '#title returns the title wrapped in a h3 tag if title is set' do
    assert_dom_equal '<h3>Optional title</h3>', item_presenter(title: 'Optional title', title_url: '').title
  end

  test '#title returns the title with a link if there is a link present' do
    assert_dom_equal "<h3><a href=\"http://#{Whitehall.public_hosts.first}/page\">Optional title with link</a></h3>",
      item_presenter(title: 'Optional title with link', title_url: "http://#{Whitehall.public_hosts.first}/page").title
  end

  test '#title recognises external links and marks the appropriately' do
    assert_dom_equal '<h3><a href="http://external.com" rel="external">Optional title with link</a></h3>',
      item_presenter(title: 'Optional title with link', title_url: "http://external.com").title
  end

  private

  def item_presenter(attributes={})
    PromotionalFeatureItemPresenter.new(build(:promotional_feature_item, attributes), @view_context)
  end
end
