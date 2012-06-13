require 'test_helper'

class PersonPresenterTest < PresenterTestCase
  setup do
    @person = stub_record(:person)
    @presenter = PersonPresenter.decorate(@person)
  end

  test 'url is generated using person_url' do
    assert_equal person_url(@person), @presenter.url
  end

  test 'link links name to url' do
    @presenter.stubs(:url).returns('http://example.com/person/a-person')
    assert_select_from @presenter.link, 'a[href="http://example.com/person/a-person"]', text: @person.name
  end

  test 'image wraps img of person with figure' do
    @person.stubs(:image_url).returns('/link/to/image.jpg')
    assert_select_from @presenter.image, 'figure.img img[src="/link/to/image.jpg"]'
  end

  test 'image links to blank-person.png if person has no associated image' do
    @person.stubs(:image_url).returns(nil)
    assert_select_from @presenter.image, 'figure.img img[src="/government/assets/blank-person.png"]'
  end

  test 'image captions figure with name of person' do
    assert_select_from @presenter.image, 'figure.img figcaption', text: @person.name
  end

  test 'biography generates html from the original govspeak' do
    @person.stubs(:biography).returns("## Hello")
    assert_select_from @presenter.biography, '.govspeak h2', text: 'Hello'
  end
end