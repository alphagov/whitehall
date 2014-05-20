require 'test_helper'

class OffsiteLinkTest < ActiveSupport::TestCase

  test 'should be invalid without a title' do
    offsite_link = build(:offsite_link, title: nil)
    refute offsite_link.valid?
  end

  test 'should be invalid without a summary' do
    offsite_link = build(:offsite_link, summary: nil)
    refute offsite_link.valid?
  end

  test 'should be invalid without a url' do
    offsite_link = build(:offsite_link, url: nil)
    refute offsite_link.valid?
  end

  test 'should be invalid with a url that is not part of gov.uk' do
    offsite_link = build(:offsite_link, url: 'http://google.com')
    refute offsite_link.valid?
  end

  test 'should be valid with a gov.uk url' do
    offsite_link = build(:offsite_link, url: 'http://gov.uk/greatpage')
    assert offsite_link.valid?
  end

  test 'should be valid within a subdomain of gov.uk' do
    offsite_link = build(:offsite_link, url: 'http://education.gov.uk/greatpage')
    assert offsite_link.valid?
  end

  test 'should be valid if the type is not supported' do
    offsite_link = build(:offsite_link, link_type: 'notarealtype')
    refute offsite_link.valid?
  end

  test 'should be valid if the type an alert' do
    offsite_link = build(:offsite_link, link_type: 'alert')
    assert offsite_link.valid?
  end

  test 'should be valid if the type an blog_post' do
    offsite_link = build(:offsite_link, link_type: 'blog_post')
    assert offsite_link.valid?
  end

  test 'should be valid if the type an campaign' do
    offsite_link = build(:offsite_link, link_type: 'campaign')
    assert offsite_link.valid?
  end

  test 'should be valid if the type an careers' do
    offsite_link = build(:offsite_link, link_type: 'careers')
    assert offsite_link.valid?
  end

  test 'should be valid if the type an service' do
    offsite_link = build(:offsite_link, link_type: 'service')
    assert offsite_link.valid?
  end
end
