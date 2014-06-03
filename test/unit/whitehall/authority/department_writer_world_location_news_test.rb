require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class DepartmentWriterWorldLocationNewsTest < ActiveSupport::TestCase
  def department_writer(id = 1)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, organisation: nil)
  end

  include AuthorityTestHelper

  test 'can create a new world location news article' do
    assert enforcer_for(department_writer, WorldLocationNewsArticle).can?(:create)
  end

  test 'can see an world location news article that is not access limited' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:see)
  end

  test 'can see an world location news article that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = department_writer
    user.stubs(:organisation).returns(org)
    edition = limited_world_location_news_article([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an world location news article that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    edition = limited_world_location_news_article([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to an world location news article they are not allowed to see' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    edition = limited_world_location_news_article([org2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::WorldEditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new world location news article of a document that is not access limited' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:create)
  end

  test 'can make changes to an world location news article that is not access limited' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:update)
  end

  test 'can delete an world location news article that is not access limited' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:delete)
  end

  test 'can make a fact check request for an world location news article' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:make_fact_check)
  end

  test 'can view fact check requests on an world location news article' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:review_fact_check)
  end

  test 'cannot publish an world location news article' do
    refute enforcer_for(department_writer, normal_world_location_news_article).can?(:publish)
  end

  test 'cannot reject an world location news article' do
    refute enforcer_for(department_writer, normal_world_location_news_article).can?(:reject)
  end

  test 'cannot force publish a world location news article' do
    refute enforcer_for(department_writer, normal_world_location_news_article).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:review_editorial_remark)
  end

  test 'cannot clear the "not reviewed" flag on world location news article' do
    refute enforcer_for(department_writer, normal_world_location_news_article).can?(:approve)
  end

  test 'can limit access to an world location news article' do
    assert enforcer_for(department_writer, normal_world_location_news_article).can?(:limit_access)
  end

  test 'cannot unpublish an world location news article' do
    refute enforcer_for(department_writer, normal_world_location_news_article).can?(:unpublish)
  end
end
