require "test_helper"

class PublicationTest < ActiveSupport::TestCase
  include DocumentBehaviour

  test 'should be invalid without a publication date' do
    publication = build(:publication, publication_date: nil)
    refute publication.valid?
  end

  test "should be valid without Command paper number" do
    publication = build(:publication, command_paper_number: nil)
    assert publication.valid?
  end

  test "should be valid with blank Command paper number" do
    publication = build(:publication, command_paper_number: '')
    assert publication.valid?
  end

  ['C.', 'Cd.', 'Cmd.', 'Cmnd.', 'Cm.'].each do |prefix|
    test "should be valid when the Command paper number starts with '#{prefix}'" do
      publication = build(:publication, command_paper_number: "#{prefix} 1234")
      assert publication.valid?
    end
  end

  test "should be invalid when the command paper number starts with an unrecognised prefix" do
    publication = build(:publication, command_paper_number: "NA 1234")
    refute publication.valid?
    expected_message = "is invalid. The number must start with one of #{Publication::VALID_COMMAND_PAPER_NUMBER_PREFIXES.join(', ')}"
    assert publication.errors[:command_paper_number].include?(expected_message)
  end

  test 'should be invalid with malformed order url' do
    publication = build(:publication, order_url: "invalid-url")
    refute publication.valid?
  end

  test 'should be valid with order url with HTTP protocol' do
    publication = build(:publication, order_url: "http://example.com")
    assert publication.valid?
  end

  test 'should be valid with order url with HTTPS protocol' do
    publication = build(:publication, order_url: "https://example.com")
    assert publication.valid?
  end

  test 'should be valid without order url' do
    publication = build(:publication, order_url: nil)
    assert publication.valid?
  end

  test 'should be valid with blank order url' do
    publication = build(:publication, order_url: nil)
    assert publication.valid?
  end

  test 'should be valid if the price is nil' do
    publication = build(:publication, price: nil)
    assert publication.valid?
  end

  test 'should be valid if the price is blank' do
    publication = build(:publication, price: '')
    assert publication.valid?
  end

  test 'should be valid if the price appears to be in whole pounds' do
    publication = build(:publication, price: "9", order_url: 'http://example.com')
    assert publication.valid?
  end

  test 'should be valid if the price is in pounds and pence' do
    publication = build(:publication, price: "1.23", order_url: 'http://example.com')
    assert publication.valid?
  end

  test 'should be invalid if the price is non numeric' do
    publication = build(:publication, price: 'free', order_url: 'http://example.com')
    refute publication.valid?
  end

  test 'should be invalid if the price is zero' do
    publication = build(:publication, price: "0", order_url: 'http://example.com')
    refute publication.valid?
  end

  test 'should be invalid if the price is less than zero' do
    publication = build(:publication, price: "-1.23", order_url: 'http://example.com')
    refute publication.valid?
  end

  test 'should be invalid if a price is entered without an order url' do
    publication = build(:publication, price: "123")
    refute publication.valid?
  end

  test "should build a draft copy of the existing publication" do
    attachment = create(:attachment)
    published_publication = create(:published_publication,
      publication_date: Date.parse("2010-01-01"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id,
      order_url: "http://example.com/order-url",
      attachments: [attachment],
      price_in_pence: 123
    )

    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert_kind_of Attachment, published_publication.attachments.first
    assert_equal published_publication.attachments, draft_publication.attachments
    assert_equal published_publication.publication_date, draft_publication.publication_date
    assert_equal published_publication.publication_type, draft_publication.publication_type
    assert_equal published_publication.order_url, draft_publication.order_url
    assert_equal published_publication.price_in_pence, draft_publication.price_in_pence
  end

  test "allows attachment" do
    assert build(:publication).allows_attachments?
  end

  test "should allow multiple attachments" do
    attachment_1 = create(:attachment)
    attachment_2 = create(:attachment)

    publication = create(:publication, attachments: [attachment_1, attachment_2])

    assert_equal [attachment_1, attachment_2], publication.attachments
  end

  test "should allow deletion of attachments via nested attributes" do
    attachment_1 = create(:attachment)
    attachment_2 = create(:attachment)

    publication = create(:publication, attachments: [attachment_1, attachment_2])

    edition_attachments_attributes = publication.edition_attachments.inject({}) do |h, da|
      h[da.id] = da.attributes.merge("_destroy" => (da.attachment == attachment_1 ? "1" : "0"))
      h
    end
    publication.update_attributes(edition_attachments_attributes: edition_attachments_attributes)
    publication.reload

    assert_equal [attachment_2], publication.attachments
  end

  test "should allow setting of publication type" do
    publication = build(:publication, publication_type: PublicationType::PolicyPaper)
    assert publication.valid?
  end

  test "should be invalid without a publication type" do
    publication = build(:publication, publication_type: nil)
    refute publication.valid?
  end
end

class PublicationsInTopicsTest < ActiveSupport::TestCase
  def setup
    @policy_1 = create(:published_policy)
    @topic_1 = create(:topic, policies: [@policy_1])
    @policy_2 = create(:published_policy)
    @topic_2 = create(:topic, policies: [@policy_2])
    @draft_policy = create(:draft_policy)
    @topic_with_draft_policy = create(:topic, policies: [@draft_policy])
  end

  test "should be able to find a publication using the topic of an associated policy" do
    published_publication = create(:published_publication, related_policies: @topic_1.policies)

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
  end

  test "should return the publications with the given policy but not other policies" do
    published_publication_1 = create(:published_publication, related_policies: @topic_1.policies)
    published_publication_2 = create(:published_publication, related_policies: @topic_1.policies + @topic_2.policies)

    assert_equal [published_publication_1, published_publication_2], Publication.in_topic([@topic_1]).all
    assert_equal [published_publication_2], Publication.in_topic([@topic_2]).all
  end

  test "should ignore non-integer topic ids" do
    assert_equal [], Publication.in_topic(["'bad"]).all
  end

  test "returns publications with any of the listed topics" do
    publications = [
      create(:published_publication, related_policies: @topic_1.policies),
      create(:published_publication, related_policies: @topic_2.policies)
    ]

    assert_equal publications, Publication.in_topic([@topic_1, @topic_2]).all
  end

  test "should only find published publications, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1])
    create(:draft_publication, related_policies: [@policy_1])

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
  end

  test "should only consider associations through published policies, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1, @draft_policy])

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
    assert_equal [], Publication.in_topic([@topic_with_draft_policy]).all
  end

  test "should consider the topics of the latest published edition of a policy" do
    user = create(:departmental_editor)
    policy_1_b = @policy_1.create_draft(user)
    topic_1_b = create(:topic, policies: [policy_1_b])
    published_publication = create(:published_publication, related_policies: [policy_1_b])

    assert_equal [], Publication.in_topic([topic_1_b]).all

    policy_1_b.change_note = "test"
    assert policy_1_b.publish_as(user, force: true), "Should be able to publish"
    topic_1_b.reload
    assert_equal [published_publication], Publication.in_topic([topic_1_b]).all
  end

  test "should save the price as price_in_pence" do
    publication = create(:publication, price: "1.23", order_url: 'http://example.com')
    publication.reload
    assert_equal 123, publication.price_in_pence
  end

  test "should save the price as nil if an existing price_in_pence is being reset to blank" do
    publication = create(:publication, price_in_pence: 999, order_url: 'http://example.com')
    publication.price = ''
    publication.save!
    publication.reload
    assert_equal nil, publication.price_in_pence
  end

  test "should not save a nil price as a zero price_in_pence" do
    publication = create(:publication, price: nil, order_url: 'http://example.com')
    publication.reload
    assert_equal nil, publication.price_in_pence
  end

  test "should not save a blank price as a zero price_in_pence" do
    publication = create(:publication, price: '', order_url: 'http://example.com')
    publication.reload
    assert_equal nil, publication.price_in_pence
  end

  test "should prefer the memoized price over price_in_pence" do
    publication = build(:publication, price: "1.23", price_in_pence: 345)
    assert_equal "1.23", publication.price
  end

  test "should convert price_in_pence to price in pounds when a new price hasn't been set" do
    publication = build(:publication, price_in_pence: 345)
    assert_equal 3.45, publication.price
  end

  test "should return nil if neither price nor price_in_pence are set" do
    publication = build(:publication, price: nil, price_in_pence: nil)
    assert_nil publication.price
  end

  test "should find publication with title containing keyword" do
    publication_without_keyword = create(:publication, title: "title that should not be found")
    publication_with_keyword = create(:publication, title: "title containing keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("keyword")
  end

  test "should find publication with body containing keyword" do
    publication_without_keyword = create(:publication, body: "body that should not be found")
    publication_with_keyword = create(:publication, body: "body containing keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("keyword")
  end

  test "should find publications containing any of the keywords" do
    publication_with_first_keyword = create(:publication, body: "this document is about muppets")
    publication_with_second_keyword = create(:publication, body: "this document is about klingons")
    assert_equal [publication_with_first_keyword, publication_with_second_keyword], Publication.with_content_containing("klingons", "muppets")
  end

  test "should find publications containing keyword regardless of case" do
    publication_with_keyword = create(:publication, body: "body containing Keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("keyword")
  end

  test "should find publications containing keyword as part of a word" do
    publication_with_keyword = create(:publication, body: "body containing keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("key")
  end
end
