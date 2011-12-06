require "test_helper"

class PolicyAreasControllerTest < ActionController::TestCase
  test "shows policy area title and description" do
    policy_area = create(:policy_area)
    get :show, id: policy_area
    assert_select ".policy_area .name", text: policy_area.name
    assert_select ".policy_area .description", text: policy_area.description
  end

  test "shows published policies associated with policy area" do
    published_policy = create(:published_policy)
    policy_area = create(:policy_area, documents: [published_policy])

    get :show, id: policy_area

    assert_select "#policies" do
      assert_select_object(published_policy, count: 1)
    end
  end

  test "doesn't show unpublished policies" do
    draft_policy = create(:draft_news_article)
    policy_area = create(:policy_area, documents: [draft_policy])

    get :show, id: policy_area

    refute_select_object(draft_policy)
  end

  test "should not display an empty published policies section" do
    policy_area = create(:policy_area)
    get :show, id: policy_area
    refute_select "#policies"
  end

  test "show displays recently changed documents relating to policies in the policy area" do
    policy_1 = create(:published_policy)
    publication_1 = create(:published_publication, documents_related_to: [policy_1])
    news_article_1 = create(:published_news_article, documents_related_to: [policy_1])
    consultation = create(:published_consultation, documents_related_to: [policy_1])

    policy_2 = create(:published_policy)
    news_article_2 = create(:published_news_article, documents_related_to: [policy_2])
    publication_2 = create(:published_publication, documents_related_to: [policy_2])
    speech = create(:published_speech, documents_related_to: [policy_2])

    policy_area = create(:policy_area, documents: [policy_1, policy_2])

    get :show, id: policy_area

    assert_select "#recently-changed" do
      assert_select_object news_article_1
      assert_select_object news_article_2
      assert_select_object publication_1
      assert_select_object publication_2
      assert_select_object consultation
      assert_select_object speech
    end
  end

  test "show displays metadata about the recently changed documents" do
    published_at = Time.zone.now
    speech = create(:published_speech_transcript, published_at: published_at)
    policy = create(:published_policy,
      documents_related_with: [speech]
    )

    policy_area = create(:policy_area, documents: [policy])

    get :show, id: policy_area

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select '.metadata .document_type', text: "Speech"
        assert_select ".metadata .published_at[title='#{published_at.iso8601}']"
      end
    end
  end

  test "show displays recently changed documents in order of publication date with most recent first" do
    policy_1 = create(:published_policy)
    publication_1 = create(:published_publication, published_at: 4.weeks.ago, documents_related_to: [policy_1])
    news_article_1 = create(:published_news_article, published_at: 1.week.ago, documents_related_to: [policy_1])

    policy_2 = create(:published_policy)
    news_article_2 = create(:published_news_article, published_at: 3.weeks.ago, documents_related_to: [policy_2])
    publication_2 = create(:published_publication, published_at: 2.weeks.ago, documents_related_to: [policy_2])

    policy_area = create(:policy_area, documents: [policy_1, policy_2])

    get :show, id: policy_area

    assert_equal [news_article_1, publication_2, news_article_2, publication_1], assigns[:recently_changed_documents]
  end

  test "should show list of policy areas with published documents" do
    policy_area_1, policy_area_2 = create(:policy_area), create(:policy_area)
    PolicyArea.stubs(:with_published_documents).returns([policy_area_1, policy_area_2])
    PolicyAreasController::FeaturedPolicyAreaChooser.stubs(:choose_policy_area)

    get :index

    assert_select_object(policy_area_1)
    assert_select_object(policy_area_2)
  end

  test "should not display an empty list of policy areas" do
    PolicyArea.stubs(:with_published_documents).returns([])
    PolicyAreasController::FeaturedPolicyAreaChooser.stubs(:choose_policy_area)

    get :index

    refute_select ".policy_areas"
  end

  test "shows a featured policy area if one exists" do
    policy_area = create(:policy_area)
    PolicyAreasController::FeaturedPolicyAreaChooser.stubs(:choose_policy_area).returns(policy_area)

    get :index

    assert_select ".featured" do
      assert_select_object(policy_area)
    end
  end

  test "shows featured policy area policies" do
    policy = create(:published_policy)
    policy_area = create(:policy_area, documents: [policy])
    PolicyAreasController::FeaturedPolicyAreaChooser.stubs(:choose_policy_area).returns(policy_area)

    get :index

    assert_select_object policy
  end

  test "shows a maximum of 2 featured policy area policies" do
    policies = [create(:published_policy), create(:published_policy), create(:published_policy)]
    policy_area = create(:policy_area, documents: policies)
    PolicyAreasController::FeaturedPolicyAreaChooser.stubs(:choose_policy_area).returns(policy_area)

    get :index

    assert_select ".featured .policy", count: 2
  end

  class FeaturedPolicyAreaChooserTest < ActiveSupport::TestCase
    test "chooses random featured policy area if one exists" do
      PolicyAreasController::FeaturedPolicyAreaChooser.stubs(:choose_random_featured_policy_area).returns(:random_featured_policy_area)
      PolicyAreasController::FeaturedPolicyAreaChooser.expects(:choose_random_policy_area).never
      assert_equal :random_featured_policy_area, PolicyAreasController::FeaturedPolicyAreaChooser.choose_policy_area
    end

    test "chooses random policy area if no featured policy areas found" do
      PolicyAreasController::FeaturedPolicyAreaChooser.stubs(:choose_random_featured_policy_area).returns(nil)
      PolicyAreasController::FeaturedPolicyAreaChooser.expects(:choose_random_policy_area).returns(:random_policy_area)
      assert_equal :random_policy_area, PolicyAreasController::FeaturedPolicyAreaChooser.choose_policy_area
    end

    test "chooses a featured policy area at random" do
      available_featured_policy_areas = Array.new(2) { create(:featured_policy_area) }
      repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time = 10
      randomly_chosen_featured_policy_areas = (0..repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time).collect do
        PolicyAreasController::FeaturedPolicyAreaChooser.choose_random_featured_policy_area
      end
      assert_equal available_featured_policy_areas.uniq.sort, randomly_chosen_featured_policy_areas.uniq.sort
    end

    test "never chooses a non-featured policy area" do
      non_featured_policy_area = create(:policy_area)
      repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time = 10
      (0..repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time).collect do
        assert_nil PolicyAreasController::FeaturedPolicyAreaChooser.choose_random_featured_policy_area
      end
    end

    test "chooses a policy area with published documents at random" do
      available_policy_areas = Array.new(2) { create(:policy_area, documents: [create(:published_document)]) }
      repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time = 10
      randomly_chosen_policy_areas = (0..repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time).collect do
        PolicyAreasController::FeaturedPolicyAreaChooser.choose_random_policy_area
      end
      assert_equal available_policy_areas.uniq.sort, randomly_chosen_policy_areas.uniq.sort
    end

    test "never chooses a policy area without published documents" do
      policy_area_without_published_document = create(:policy_area)
      repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time = 10
      (0..repetitions_to_reduce_the_chance_of_getting_the_same_policy_area_each_time).collect do
        assert_nil PolicyAreasController::FeaturedPolicyAreaChooser.choose_random_policy_area
      end
    end
  end
end