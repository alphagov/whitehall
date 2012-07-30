# encoding: utf-8

require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :publication
  should_show_related_policies_and_topics_for :publication
  should_show_the_countries_associated_with :publication
  should_display_inline_images_for :publication
  should_not_display_lead_image_for :publication
  should_show_change_notes :publication

  test 'show displays published publications' do
    published_publication = create(:published_publication)
    get :show, id: published_publication.document
    assert_response :success
  end

  test "renders the publication summary from plain text" do
    publication = create(:published_publication, summary: 'plain text & so on')
    get :show, id: publication.document

    assert_select ".summary", text: "plain text &amp; so on"
  end

  test "show renders the publication body using govspeak" do
    publication = create(:published_publication, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: publication.document
    end

    assert_select ".body", text: "body-in-html"
  end

  test "show displays inapplicable nations" do
    published_publication = create(:published_publication)
    northern_ireland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_publication.document

    assert_select inapplicable_nations_selector do
      assert_select "p", "This publication does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "show should not explicitly say that publication applies to the whole of the UK" do
    published_publication = create(:published_publication)

    get :show, id: published_publication.document

    refute_select inapplicable_nations_selector
  end

  test "show should display publication metadata" do
    publication = create(:published_publication,
      publication_date: Date.parse("1916-05-31"),
      publication_type_id: PublicationType::Form.id
    )

    get :show, id: publication.document

    assert_select ".contextual-info" do
      assert_select ".publication_type", text: "Form"
      assert_select ".publication_date", text: "31 May 1916"
    end
  end

  def assert_featured(doc)
    assert_select "#{record_css_selector(doc)}.featured"
  end

  test "show should display a National Statistic badge on the appropriate documents" do
    publication = create(:published_publication, publication_type_id: PublicationType::NationalStatistics.id)
    get :show, id: publication.document

    assert_match /National Statistic/, response.body
  end

  test "index only displays published publications" do
    archived_publication = create(:archived_publication)
    published_publication = create(:published_publication)
    draft_publication = create(:draft_publication)
    get :index

    assert_select_object(published_publication)
    refute_select_object(archived_publication)
    refute_select_object(draft_publication)
  end

  test 'index should not use n+1 selects' do
    10.times { create(:published_publication) }
    assert 10 > count_queries { get :index }
  end

  test "index can be filtered by the topic of the associated policy" do
    given_two_publications_in_two_topics

    get :index, topics: [@topic_1]

    assert_select_object @published_publication
    refute_select_object @published_in_second_topic
  end

  test "index can be filtered by an organisation" do
    given_two_publications_in_two_organisations

    get :index, departments: [@organisation_1]

    assert_select_object @publication_in_organisation_1
    refute_select_object @publication_in_organisation_2
  end

  test "index can be filtered by a keyword" do
    publication_without_keyword = create(:published_publication, body: "body that should not be found")
    publication_with_keyword = create(:published_publication, body: "body containing keyword in the middle")

    get :index, keywords: "keyword"

    assert_select_object publication_with_keyword
    refute_select_object publication_without_keyword
  end

  test "index can be filtered after a date" do
    publication_published_before_date = create(:published_publication, publication_date: 3.months.ago)
    publication_published_after_date = create(:published_publication, publication_date: 1.month.ago)

    get :index, direction: "after", date: 2.months.ago

    refute_select_object publication_published_before_date
    assert_select_object publication_published_after_date
  end

  test "index can be filtered before a date" do
    publication_published_before_date = create(:published_publication, publication_date: 3.months.ago)
    publication_published_after_date = create(:published_publication, publication_date: 1.month.ago)

    get :index, direction: "before", date: 2.months.ago

    assert_select_object publication_published_before_date
    refute_select_object publication_published_after_date
  end

  test "index can be filtered by the union of multiple topics" do
    given_two_publications_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select_object @published_publication
    assert_select_object @published_in_second_topic
  end

  test "index can be filtered by the union of multiple organisations" do
    given_two_publications_in_two_organisations

    get :index, departments: [@organisation_1, @organisation_2]

    assert_select_object @publication_in_organisation_1
    assert_select_object @publication_in_organisation_2
  end

  test "index can be filtered by multiple keywords" do
    publication_with_first_keyword = create(:published_publication, body: "this document is about muppets")
    publication_with_second_keyword = create(:published_publication, body: "this document is about klingons")

    get :index, keywords: "Klingons Muppets"

    assert_select_object publication_with_first_keyword
    assert_select_object publication_with_second_keyword
  end

  test "index only lists topics with associated published editions" do
    given_two_publications_in_two_topics
    another_topic = create(:topic, policies: [create(:draft_policy)])

    get :index

    refute assigns[:all_topics].include?(another_topic)
  end

  test "index lists topic filter options in alphabetical order" do
    topic_1 = create(:topic, name: "Yak shaving")
    topic_2 = create(:topic, name: "Aardvark protection")
    create_publications_in(topic_1, topic_2)

    get :index

    assert_equal ["Aardvark protection", "Yak shaving"], assigns[:all_topics].map(&:name)
  end

  test "index lists organisations with publicationsi in alphabetical order ignoring prefix" do
    organisation_1 = create(:organisation, name: "Department of yak shaving")
    publication_1 = create(:published_publication, organisations: [organisation_1])
    organisation_2 = create(:organisation, name: "Ministry of aardvark protection")
    publication_2 = create(:published_publication, organisations: [organisation_2])

    get :index

    assert_equal ["Ministry of aardvark protection", "Department of yak shaving"], assigns[:all_organisations].map(&:name)
  end

  test "index highlights selected topic filter options" do
    given_two_publications_in_two_topics

    get :index, topics: [@topic_1, @topic_2]

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: @topic_1.name
      assert_select "option[selected='selected']", text: @topic_2.name
    end
  end

  test "index highlights selected organisation filter options" do
    given_two_publications_in_two_organisations

    get :index, departments: [@organisation_1, @organisation_2]

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: @organisation_1.name
      assert_select "option[selected='selected']", text: @organisation_2.name
    end
  end

  test "index displays filter keywords" do
    get :index, keywords: "olympics 2012"

    assert_select "input[name='keywords'][value=?]", "olympics 2012"
  end

  test "index displays selected date filter" do
    get :index, direction: "before", date: "2010-01-01"

    assert_select "input#direction_before[name='direction'][checked=checked]"
    assert_select "select[name='date']" do
      assert_select "option[selected='selected'][value=?]", "2010-01-01"
    end
  end

  test "index highlights all topics filter option by default" do
    given_two_publications_in_two_topics

    get :index

    assert_select "select[name='topics[]']" do
      assert_select "option[selected='selected']", text: "All topics"
    end
  end

  test "index highlights all organisations filter options by default" do
    given_two_publications_in_two_organisations

    get :index

    assert_select "select[name='departments[]']" do
      assert_select "option[selected='selected']", text: "All departments"
    end
  end

  test "index shows filter keywords placeholder by default" do
    get :index

    assert_select "input[name='keywords'][placeholder=?]", "keywords"
  end

  test "index does not select a date filter by default" do
    get :index

    assert_select "select[name='date']" do
      refute_select "option[selected='selected']"
    end
  end

  test 'index should not use n+1 selects when filtering by topics' do
    policy = create(:published_policy)
    topic = create(:topic, policies: [policy])
    15.times { create(:published_publication, related_policies: [policy]) }
    assert 15 > count_queries { get :index, topics: [topic] }
  end

  test 'index should not use n+1 selects when filtering by organisations' do
    organisation = create(:organisation)
    15.times { create(:published_publication, organisations: [organisation]) }
    assert 15 > count_queries { get :index, departments: [organisation] }
  end

  test 'index should not use n+1 selects when filtering by keywords' do
    15.times { |i| create(:published_publication, title: "keyword-#{i}") }
    assert 15 > count_queries { get :index, keywords: "keyword" }
  end

  test 'index should not use n+1 selects when filtering by date' do
    15.times { |i| create(:published_publication, publication_date: i.months.ago) }
    assert 15 > count_queries { get :index, direction: "after", date: 6.months.ago }
  end

  test "index lists publications in chronological order when filtered after a date" do
    publication_published_second = create(:published_publication, publication_date: 1.month.ago)
    publication_published_first = create(:published_publication, publication_date: 2.months.ago)

    get :index, direction: "after", date: 3.months.ago

    assert_equal [publication_published_first, publication_published_second], assigns[:publications]
  end

  test "index lists publications in reverse chronological order when filtered before a date" do
    publication_published_first = create(:published_publication, publication_date: 3.months.ago)
    publication_published_second = create(:published_publication, publication_date: 2.month.ago)

    get :index, direction: "before", date: 1.month.ago

    assert_equal [publication_published_second, publication_published_first], assigns[:publications]
  end

  test "index lists publications in reverse chronological order by default" do
    publication_published_first = create(:published_publication, publication_date: 3.months.ago)
    publication_published_second = create(:published_publication, publication_date: 2.month.ago)

    get :index

    assert_equal [publication_published_second, publication_published_first], assigns[:publications]
  end

  test "index should show a helpful message if there are no matching publications" do
    get :index

    assert_select "h2", text: "There are no matching publications."
  end

  test "index should only show a certain number of publications by default" do
    publications = (1..25).to_a.map { |i| create(:published_publication, title: "keyword-#{i}-index-default", publication_date: i.days.ago) }

    get :index

    (0..19).to_a.each { |i| assert_select_object(publications[i]) }
    (20..24).to_a.each { |i| refute_select_object(publications[i]) }
  end

  test "index should show window of pagination" do
    publications = (1..25).to_a.map { |i| create(:published_publication, title: "keyword-#{i}-window-pagination", publication_date: i.days.ago) }

    get :index, page: 2

    (0..19).to_a.each { |i| refute_select_object(publications[i]) }
    (20..24).to_a.each { |i| assert_select_object(publications[i]) }
  end

  test "show more button should not appear by default" do
    publications = (1..18).to_a.map { |i| create(:published_publication, title: "keyword-#{i}") }

    get :index

    refute_select "#show-more-publications"
  end

  test "show more button should appear when there are more records" do
    publications = (1..25).to_a.map { |i| create(:published_publication, title: "keyword-#{i}") }

    get :index

    assert_select "#show-more-publications"
  end

  test "should show previous page link when not on the first page" do
    publications = (1..25).to_a.map { |i| create(:published_publication, title: "keyword-#{i}") }

    get :index, page: 2

    assert_select "#show-more-publications" do
      assert_select ".previous"
      refute_select ".next"
    end
  end

  test "should show progress helpers in pagination links" do
    publications = (1..45).to_a.map { |i| create(:published_publication, title: "keyword-#{i}") }

    get :index, page: 2

    assert_select "#show-more-publications" do
      assert_select ".previous span", text: "1 of 3"
      assert_select ".next span", text: "3 of 3"
    end
  end

  test "show displays the ISBN of the attached document" do
    attachment = create(:attachment, isbn: '0099532816')
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".isbn", "0099532816"
    end
  end

  test "show doesn't display an empty ISBN if none exists for the attachment" do
    attachment = create(:attachment, isbn: nil)
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      refute_select ".isbn"
    end
  end

  test "show displays the Unique Reference Number of the attached document" do
    attachment = create(:attachment, unique_reference: 'unique-reference')
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".unique_reference", "unique-reference"
    end
  end

  test "show doesn't display an empty Unique Reference Number if none exists for the attachment" do
    attachment = create(:attachment, unique_reference: nil)
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      refute_select ".unique_reference"
    end
  end

  test "show displays the Command Paper number of the attached document" do
    attachment = create(:attachment, command_paper_number: 'Cm. 1234')
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".command_paper_number", "Cm. 1234"
    end
  end

  test "show doesn't display an empty Command Paper number if none exists for the attachment" do
    attachment = create(:attachment, command_paper_number: nil)
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      refute_select ".command_paper_number"
    end
  end

  test "show links to the url that the attachment can be ordered from" do
    attachment = create(:attachment, order_url: 'http://example.com/order-path')
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".order_url", /order a copy/i
    end
  end

  test "show doesn't display an empty order url if none exists for the attachment" do
    attachment = create(:attachment, order_url: nil)
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      refute_select ".order_url"
    end
  end

  test "show displays the price of the purchasable attachment" do
    attachment = create(:attachment, price: "1.23", order_url: 'http://example.com')
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      assert_select ".price", text: "£1.23"
    end
  end

  test "show doesn't display an empty price if none exists for the attachment" do
    attachment = create(:attachment, price: nil)
    edition = create("published_publication", body: "!@1", attachments: [attachment])

    get :show, id: edition.document

    assert_select_object(attachment) do
      refute_select ".price"
    end
  end

  private

  def given_two_publications_in_two_organisations
    @organisation_1, @organisation_2 = create(:organisation), create(:organisation)
    @publication_in_organisation_1 = create(:published_publication, organisations: [@organisation_1])
    @publication_in_organisation_2 = create(:published_publication, organisations: [@organisation_2])
  end

  def given_two_publications_in_two_topics
    @topic_1, @topic_2 = create(:topic), create(:topic)
    @published_publication, @published_in_second_topic = create_publications_in(@topic_1, @topic_2)
  end

  def create_publications_in(*topics)
    topics.map do |topic|
      policy = create(:published_policy)
      topic.policies << policy
      publication = create(:published_publication, related_policies: [policy])
      topic.update_counts
      publication
    end
  end

end
