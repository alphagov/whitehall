require "test_helper"

class Edition::WorkflowTest < ActiveSupport::TestCase
  test "indicates pre-publication status" do
    pre, post = Edition.state_machine.states.map(&:name).partition do |state|
      if state == :deleted
        create(:edition, state: state)
      else
        build(:edition, state: state)
      end.pre_publication?
    end

    assert_equal [:imported, :draft, :submitted, :rejected, :scheduled], pre
    assert_equal [:published, :superseded, :deleted, :withdrawn], post
  end

  test "rejecting a submitted edition transitions it into the rejected state" do
    submitted_edition = create(:submitted_edition)
    submitted_edition.reject!
    assert submitted_edition.rejected?
  end

  [:draft, :scheduled, :published, :superseded, :deleted, :withdrawn].each do |state|
    test "should prevent a #{state} edition being rejected" do
      edition = create("#{state}_edition")
      edition.reject! rescue nil
      refute edition.rejected?
    end
  end

  [:draft, :rejected].each do |state|
    test "submitting a #{state} edition transitions it into the submitted state" do
      edition = create("#{state}_edition")
      edition.submit!
      assert edition.submitted?
    end
  end

  [:scheduled, :published, :superseded, :deleted, :withdrawn].each do |state|
    test "should prevent a #{state} edition being submitted" do
      edition = create("#{state}_edition")
      edition.submit! rescue nil
      refute edition.submitted?
    end
  end

  [:draft, :submitted, :scheduled, :rejected, :deleted, :withdrawn].each do |state|
    test "should prevent a #{state} edition being superseded" do
      edition = create("#{state}_edition")
      edition.supersede! rescue nil
      refute edition.superseded?
    end
  end

  test "should not find deleted editions by default" do
    edition = create(:deleted_edition)
    assert_nil Edition.find_by(id: edition.id)
  end

  [:draft, :submitted, :rejected].each do |state|
    test "should be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      assert edition.valid?
    end
  end

  [:scheduled, :published, :superseded, :deleted].each do |state|
    test "should not be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      refute edition.valid?
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:title]
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:body]
    end
  end

  test "should be able to change major_change_published_at and first_published_at when scheduled" do
    edition = create(:edition, :scheduled)
    edition.first_published_at = Time.zone.now
    edition.major_change_published_at = Time.zone.now
    assert edition.valid?
  end

  test "#save_as saves the edition" do
    edition = create(:publication)
    edition.expects(:save)
    edition.save_as(create(:user))
  end

  test "#save_as records the new creator if save succeeds" do
    edition = create(:publication)
    edition.stubs(:save).returns(true)
    user = create(:user)
    edition.save_as(user)
    assert_equal 2, edition.edition_authors.count
    assert_equal user, edition.edition_authors.last.user
  end

  test "#save_as does not record new creator if save fails" do
    edition = create(:publication)
    edition.stubs(:save).returns(true)
    user = create(:user)
    edition.save_as(user)
    assert_equal 2, edition.edition_authors.count
    assert_equal user, edition.edition_authors.last.user
  end

  test "#save_as returns true if save succeeds" do
    edition = create(:publication)
    edition.stubs(:save).returns(true)
    assert edition.save_as(create(:user))
  end

  test "#save_as updates the document slug if this is the first draft" do
    edition = create(:submitted_publication, title: "First Title")
    edition.save_as(user = create(:user))

    edition.title = "Second Title"
    edition.save_as(user)
    publish(edition)

    assert_nil Publication.published_as("first-title")
    assert_equal edition, Publication.published_as("second-title")
  end

  test "#save_as does not alter the slug if this edition has previously been published" do
    edition = create(:submitted_publication, title: "First Title")
    edition.save_as(user = create(:user))
    publish(edition)

    new_draft = edition.create_draft(user)
    new_draft.title = "Second Title"
    new_draft.change_note = "change-note"
    new_draft.save_as(user)
    new_draft.submit!
    publish(new_draft)

    assert_equal new_draft, Publication.published_as("first-title")
    assert_nil Publication.published_as("second-title")
  end

  test "#save_as returns false if save fails" do
    edition = create(:publication)
    edition.stubs(:save).returns(false)
    refute edition.save_as(create(:user))
  end

  test "#supersede! on a depended-upon edition destroys its dependencies" do
    edition = create(:published_news_article)
    edition.depended_upon_contacts << create(:contact)
    edition.depended_upon_editions << create(:speech)

    assert edition.supersede!

    assert_empty edition.depended_upon_contacts.reload
    assert_empty edition.depended_upon_editions.reload
  end

  test "supersede! on a depended-upon edition destroys links with its dependent editions" do
    stub_any_publishing_api_call
    dependable_speech = create(:submitted_speech)
    dependent_article = create(:published_news_article, major_change_published_at: Time.zone.now,
      body: "Read our [official statement](/government/admin/speeches/#{dependable_speech.id})")
    dependent_article.depended_upon_editions << dependable_speech

    dependable_speech.major_change_published_at = Time.zone.now
    assert Whitehall.edition_services.publisher(dependable_speech).perform!
    dependable_speech.supersede!

    assert_empty dependable_speech.dependent_editions.reload
  end

  test "#has_workflow? returns true" do
    edition = create(:publication)
    assert edition.has_workflow?
  end
end
