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

  test 'should be valid with a gov.wales url' do
    offsite_link = build(:offsite_link, url: 'http://gov.wales/page')
    assert offsite_link.valid?
  end

  test 'should be valid with whitelisted urls' do
    whitelisted_urls = [
      'http://www.flu-lab-net.eu',
      'http://www.tse-lab-net.eu',
      'http://beisgovuk.citizenspace.com',
      'http://www.nhs.uk',
    ]
    whitelisted_urls.each do |url|
      assert build(:offsite_link, url: url).valid?, "#{url} not valid"
    end
  end

  test 'should not be valid with almost whitelisted urls' do
    whitelisted_urls = [
      'http://someotherflu-lab-net.eu',
      'http://a.n.othertse-lab-net.eu',
      'http://almostbeisgovuk.citizenspace.com',
      'http://notthenhs.uk',
    ]
    whitelisted_urls.each do |url|
      refute build(:offsite_link, url: url).valid?, "#{url} is valid"
    end
  end

  test 'should not be valid if the type is not supported' do
    offsite_link = build(:offsite_link, link_type: 'notarealtype')
    refute offsite_link.valid?
  end

  test 'should be valid if the type is alert' do
    offsite_link = build(:offsite_link, link_type: 'alert')
    assert offsite_link.valid?
  end

  test 'should be valid if the type is blog_post' do
    offsite_link = build(:offsite_link, link_type: 'blog_post')
    assert offsite_link.valid?
  end

  test 'should be valid if the type is campaign' do
    offsite_link = build(:offsite_link, link_type: 'campaign')
    assert offsite_link.valid?
  end

  test 'should be valid if the type is careers' do
    offsite_link = build(:offsite_link, link_type: 'careers')
    assert offsite_link.valid?
  end

  test 'should be valid if the type is service' do
    offsite_link = build(:offsite_link, link_type: 'service')
    assert offsite_link.valid?
  end

  test 'should be valid if the type is nhs_content' do
    offsite_link = build(:offsite_link, link_type: 'nhs_content')
    assert offsite_link.valid?
  end
end
