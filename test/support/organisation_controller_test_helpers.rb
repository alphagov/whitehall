require 'gds_api/test_helpers/content_store'

module OrganisationControllerTestHelpers
  extend ActiveSupport::Concern
  include GdsApi::TestHelpers::ContentStore

  module ClassMethods
    def should_display_organisation_page_elements_for(org_type)
      test "#{org_type} sets meta description" do
        organisation = create_org_and_stub_content_store(org_type)
        create(:about_corporate_information_page, organisation: organisation, summary: 'my org description')

        get :show, params: { id: organisation }

        assert_equal 'my org description', assigns(:meta_description)
      end

      view_test "#{org_type}:shows organisation name" do
        organisation = create_org_and_stub_content_store(org_type,
          logo_formatted_name: "unformatted name"
        )
        get :show, params: { id: organisation }
        assert_select ".organisation h1", text: "unformatted name"
      end

      view_test "#{org_type}:shows a maximum of 6 featured editions" do
        organisation = create_org_and_stub_content_store(org_type)
        features = []
        feature_list = organisation.load_or_create_feature_list(:en)
        7.times do |i|
          edition = create(:published_news_article, first_published_at: i.days.ago)
          features << create(:feature, document: edition.document, feature_list: feature_list, ordering: i)
        end

        get :show, params: { id: organisation }

        assert_select_object features[0] do
          assert_select "img[src$='#{features[0].image.url(:s630)}'][alt=?]", features[0].alt_text
        end
        features[1...6].each do |feature|
          assert_select_object feature do
            assert_select "img[src$='#{feature.image.url(:s300)}'][alt=?]", feature.alt_text
          end
        end
        refute_select_object features.last.document.latest_edition
      end

      view_test "#{org_type}:should not display an empty featured editions section" do
        organisation = create_org_and_stub_content_store(org_type)
        get :show, params: { id: organisation }
        refute_select "#featured-documents article"
      end

      view_test "#{org_type}:presents the contact details of the organisation using hcard" do
        organisation = create_org_and_stub_content_store(org_type)
        organisation.contacts.create!(
          title: "Main",
          recipient: "Ministry of Pomp",
          email: "pomp@gov.uk",
          contact_form_url: "http://pomp.gov.uk/contact",
          contact_type: ContactType::General,
          street_address: "1 Smashing Place, London", postal_code: "LO1 8DN",
          contact_numbers_attributes: [
            { label: "Helpline", number: "02079460000" },
            { label: "Fax", number: "02079460001" }
          ],
          country: create(:world_location, iso2: 'GB')
        )
        organisation.add_contact_to_home_page!(organisation.contacts.first)
        get :show, params: { id: organisation }

        assert_select ".vcard" do
          assert_select ".fn", "Ministry of Pomp"
          assert_select ".adr" do
            assert_select ".street-address", "1 Smashing Place, London"
            assert_select ".postal-code", "LO1 8DN"
          end
          assert_select ".tel", /02079460000/ do
            assert_select ".type", "Helpline"
          end
          assert_select ".email", /pomp@gov\.uk/ do
            assert_select ".type", "Email"
          end
          assert_select ".contact_form_url" do
            assert_select "a[href='http://pomp.gov.uk/contact']"
          end
        end
      end

      view_test "#{org_type}:show has atom feed autodiscovery link" do
        organisation = create_org_and_stub_content_store(org_type)

        get :show, params: { id: organisation }

        assert_select_autodiscovery_link atom_feed_url_for(organisation)
      end

      view_test "#{org_type}:show includes a link to the atom feed and featured documents" do
        organisation = create_org_and_stub_content_store(org_type)
        feature_list = organisation.load_or_create_feature_list(:en)
        edition = create(:published_news_article, first_published_at: 1.days.ago)
        create(:feature, document: edition.document, feature_list: feature_list, ordering: 1)
        get :show, params: { id: organisation }

        assert_select "a.feed[href=?]", atom_feed_url_for(organisation)
      end

      view_test "#{org_type}:shows 3 most recently published editions associated with organisation when featuring a doc" do
        # different edition types sort on different attributes
        editions = [create(:published_news_article, first_published_at: 1.days.ago),
                  create(:published_publication, first_published_at: 2.days.ago),
                  create(:published_consultation, first_published_at: 3.days.ago),
                  create(:published_speech, first_published_at: 4.days.ago)]

        organisation = create_org_and_stub_content_store(org_type, editions: editions)

        feature_list = create(:feature_list, featurable: organisation, locale: :en)
        create(:feature, feature_list: feature_list, document: editions[0].document)

        get :show, params: { id: organisation }

        editions[0, 3].each do |edition|
          assert_select_prefix_object edition, :recent
        end
        refute_select_prefix_object editions[3], :recent
      end

      view_test "#{org_type}:should not show most recently published editions when there are none" do
        organisation = create_org_and_stub_content_store(org_type, editions: [])
        get :show, params: { id: organisation }

        refute_select "h1", text: "Recently updated"
      end

      view_test "#{org_type}:should show list of links to social media accounts" do
        twitter = create(:social_media_service, name: "Twitter")
        flickr = create(:social_media_service, name: "Flickr")
        twitter_account = create(:social_media_account, social_media_service: twitter, url: "https://twitter.com/#!/bisgovuk")
        flickr_account = create(:social_media_account, social_media_service: flickr, url: "http://www.flickr.com/photos/bisgovuk")
        organisation = create_org_and_stub_content_store(org_type, social_media_accounts: [twitter_account, flickr_account])

        get :show, params: { id: organisation }

        assert_select_object twitter_account
        assert_select_object flickr_account
      end

      view_test "#{org_type}:should not show list of links to social media accounts if there are none" do
        organisation = create_org_and_stub_content_store(org_type, social_media_accounts: [])

        get :show, params: { id: organisation }

        refute_select ".social-media-accounts"
      end

      view_test "#{org_type}:show has a link to govdelivery if one exists and featured documents" do
        organisation = create_org_and_stub_content_store(org_type)
        feature_list = organisation.load_or_create_feature_list(:en)
        edition = create(:published_news_article, first_published_at: 1.days.ago)
        create(:feature, document: edition.document, feature_list: feature_list, ordering: 1)

        get :show, params: { id: organisation }

        assert_select ".govdelivery[href='#{new_email_signups_path(email_signup: { feed: atom_feed_url_for(organisation) })}']"
      end

      view_test "#{org_type}:show has link to published corporate information pages" do
        organisation = create_org_and_stub_content_store(org_type)
        corporate_information_page = create(:published_corporate_information_page, organisation: organisation, corporate_information_page_type_id: CorporateInformationPageType::TermsOfReference.id)
        draft_corporate_information_page = create(:corporate_information_page, organisation: organisation, corporate_information_page_type_id: CorporateInformationPageType::ComplaintsProcedure.id)

        get :show, params: { id: organisation }

        assert_select ".corporate-information a[href='#{organisation_corporate_information_page_path(organisation, corporate_information_page.slug)}']"
        refute_select ".corporate-information a[href='#{organisation_corporate_information_page_path(organisation, draft_corporate_information_page.slug)}']"
      end
    end
  end

  def create_org_and_stub_content_store(*args)
    organisation = create(*args)
    content_item = {
      format: "organisation",
      title: "Title of organisation",
    }
    content_store_has_item(organisation.base_path, content_item)

    organisation
  end
end
