require 'test_helper'

class Admin::EditionRoutesHelperTest < ActionView::TestCase

  test 'admin_edition_path take an edition instance and uses polymorphic routes to generate the correct path' do
    p = FactoryGirl.create(:policy)
    assert_equal "/government/admin/policies/#{p.id}", admin_edition_path(p)
  end

  test 'admin_edition_url take an edition instance and uses polymorphic routes to generate the correct url' do
    s = FactoryGirl.create(:speech)
    assert_equal "http://www.gov.uk/government/admin/speeches/#{s.id}", admin_edition_url(s, host: 'www.gov.uk')
  end

  test 'edit_admin_edition_path take an edition instance and uses polymorphic routes to generate the correct path' do
    w = FactoryGirl.create(:worldwide_priority)
    assert_equal "/government/admin/priority/#{w.id}/edit", edit_admin_edition_path(w)
  end

  test 'generates supporting_pages path helper for each edition subtype' do
    Admin::EditionRoutesHelper::EDITION_TYPES.each do |edition_type|
      assert Admin::EditionRoutesHelper.instance_methods(false).include?(:"admin_#{edition_type.name.underscore}_supporting_pages_path"), "expected admin_#{edition_type.name.underscore}_supporting_pages_path to be a method on Admin::EditionRoutesHelper, but it's not"
    end
  end

  test 'supporting_pages path helper generates a generic path regardless of edition subtype' do
    n = FactoryGirl.create(:news_article)
    assert_equal "/government/admin/editions/#{n.id}/supporting-pages", admin_news_article_supporting_pages_path(n)
  end

  test 'generates editorial_remarks path helpers for each edition subtype' do
    Admin::EditionRoutesHelper::EDITION_TYPES.each do |edition_type|
      assert Admin::EditionRoutesHelper.instance_methods(false).include?(:"admin_#{edition_type.name.underscore}_editorial_remarks_path"), "expected admin_#{edition_type.name.underscore}_editorial_remarks_path to be a method on Admin::EditionRoutesHelper, but it's not"
    end
  end

  test 'editorial_remarks path helper generates a generic path regardless of edition subtype' do
    c = FactoryGirl.create(:consultation)
    assert_equal "/government/admin/editions/#{c.id}/editorial_remarks", admin_consultation_editorial_remarks_path(c)
  end

  test 'generates fact_check_requests path helpers for each edition subtype' do
    Admin::EditionRoutesHelper::EDITION_TYPES.each do |edition_type|
      assert Admin::EditionRoutesHelper.instance_methods(false).include?(:"admin_#{edition_type.name.underscore}_fact_check_requests_path"), "expected admin_#{edition_type.name.underscore}_fact_check_requests_path to be a method on Admin::EditionRoutesHelper, but it's not"
    end
  end

  test 'fact_check_requests path helper generates a generic path regardless of edition subtype' do
    p = FactoryGirl.create(:publication)
    assert_equal "/government/admin/editions/#{p.id}/fact_check_requests", admin_publication_fact_check_requests_path(p)
  end

end