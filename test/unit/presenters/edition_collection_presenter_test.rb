require 'test_helper'

class EditionCollectionPresenterTest < PresenterTestCase
  test "should wrap publicationesque things in a publicationesque presenter" do
    collection = EditionCollectionPresenter.new([Publication.new, Consultation.new, StatisticalDataSet.new])
    assert_kind_of PublicationesquePresenter, collection[0]
    assert_kind_of PublicationesquePresenter, collection[1]
    assert_kind_of PublicationesquePresenter, collection[2]
  end

  test "should wrap policies in a policy presenter" do
    collection = EditionCollectionPresenter.new([Policy.new])
    assert_kind_of PolicyPresenter, collection.first
  end

  test "should wrap speeches in a speech presenter" do
    collection = EditionCollectionPresenter.new([Speech.new])
    assert_kind_of SpeechPresenter, collection.first
  end

  test "should wrap news articles in a news article presenter" do
    collection = EditionCollectionPresenter.new([NewsArticle.new])
    assert_kind_of NewsArticlePresenter, collection.first
  end

  test "should wrap detailed guides in a detailed guide presenter" do
    collection = EditionCollectionPresenter.new([DetailedGuide.new])
    assert_kind_of DetailedGuidePresenter, collection.first
  end

  test "should wrap worldwide priority in a worldwide priority presenter" do
    collection = EditionCollectionPresenter.new([WorldwidePriority.new])
    assert_kind_of WorldwidePriorityPresenter, collection.first
  end

  test "should wrap case studies in a case study presenter" do
    collection = EditionCollectionPresenter.new([CaseStudy.new])
    assert_kind_of CaseStudyPresenter, collection.first
  end

  test "should wrap fatality notices in a fatality notice presenter" do
    collection = EditionCollectionPresenter.new([FatalityNotice.new])
    assert_kind_of FatalityNoticePresenter, collection.first
  end

  test "should wrap instances within methods that return arrays" do
    collection = EditionCollectionPresenter.new([DetailedGuide.new, Policy.new])
    assert_kind_of PolicyPresenter, collection[1,1].first
  end

  test "should not wrap anything that doesn't return an array" do
    collection = EditionCollectionPresenter.new([DetailedGuide.new, Policy.new])
    assert_equal 2, collection.length
    assert collection.any?
    refute collection.empty?
  end

  test "should wrap results of enumerating" do
    collection = EditionCollectionPresenter.new([Speech.new])
    yielded = false
    collection.each do |e|
      yielded = true
      assert_kind_of SpeechPresenter, e
    end
    assert yielded, "must actually yield!"
  end
end
