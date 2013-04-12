require 'test_helper'

class PromotionalFeatureItemPresenterTest < ActionView::TestCase
  setup do
    ApplicationController.new.set_current_view_context
  end

  test '#css_classes returns "large" for double-width items' do
    assert_nil item_presenter.css_classes
    assert_equal 'large', item_presenter(double_width: true).css_classes
  end

  test '#image_url returns 300px width images for single-width items' do
    item = item_presenter
    assert_equal item.image.s300.url, item.image_url
  end

  test '#image_url returns 630px width image path for double-width items' do
    item = item_presenter(double_width: true)
    assert_equal item.image.s630.url, item.image_url
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
  end

  test '#title returns the title wrapped in a h3 tag if title is set' do
    assert_equal '<h3>Optional title</h3>', item_presenter(title: 'Optional title').title
  end

  test '#title returns the title with a link if there is a link present' do
    assert_equal '<h3><a href="http://example.com">Optional title with link</a></h3>',
      item_presenter(title: 'Optional title with link', title_url: 'http://example.com').title
  end


  private

  def item_presenter(attributes={})
    PromotionalFeatureItemPresenter.new(build(:promotional_feature_item, attributes))
  end
end
