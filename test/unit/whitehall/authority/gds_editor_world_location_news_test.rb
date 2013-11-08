require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class GDSEditorWorldLocationNewsTest < ActiveSupport::TestCase
  def gds_editor(id = 1)
    OpenStruct.new(id: id, gds_editor?: true, organisation: nil)
  end

  include AuthorityTestHelper

  test 'can create a new WorldLocationNewsArticle' do
    assert enforcer_for(gds_editor, WorldLocationNewsArticle).can?(:create)
  end

  test 'can see a world location news article that is not access limited' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:see)
  end

  test 'can see an world location news article that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = gds_editor
    user.stubs(:organisation).returns(org)
    edition = limited_world_location_news_article([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an world location news article that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_world_location_news_article([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to an world location news article they are not allowed to see' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_world_location_news_article([org2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new edition of a world location news article that is not access limited' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:create)
  end

  test 'can make changes to a world location news article that is not access limited' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:update)
  end

  test 'can delete a world location news article that is not access limited' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:delete)
  end

  test 'can make a fact check request for a world location news article' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:make_fact_check)
  end

  test 'can view fact check requests on a world location news article' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:review_fact_check)
  end

  test 'can publish a world location news article' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:publish)
  end

  test 'cannot publish a world location news article we created' do
    me = gds_editor
    refute enforcer_for(me, normal_world_location_news_article(me)).can?(:publish)
  end

  test 'can reject a world location news article' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:reject)
  end

  test 'can force publish a world location news article' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:force_publish)
  end

  test 'can force publish a world location news article we created' do
    me = gds_editor
    assert enforcer_for(me, normal_world_location_news_article(me)).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on world location news articles they didn\'t force publish' do
    assert enforcer_for(gds_editor(10), force_published_world_location_news_article(gds_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on world location news articles they did force publish' do
    me = gds_editor
    refute enforcer_for(me, force_published_world_location_news_article(me)).can?(:approve)
  end

  test 'can limit access to a world location news article' do
    assert enforcer_for(gds_editor, normal_world_location_news_article).can?(:limit_access)
  end

  test 'cannot unpublish a world location news article' do
    refute enforcer_for(gds_editor, normal_world_location_news_article).can?(:unpublish)
  end
end
