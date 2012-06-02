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
end