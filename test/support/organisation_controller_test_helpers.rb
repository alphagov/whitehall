module OrganisationControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_display_organisation_page_elements_for(org_type)

      view_test "#{org_type}:shows organisation name" do
        organisation = create(org_type,
          logo_formatted_name: "unformatted name"
        )
        get :show, id: organisation
        assert_select ".organisation h1", text: "unformatted name"
      end

      view_test "#{org_type}:shows a maximum of 6 featured editions" do
        organisation = create(org_type)
        features = []
        feature_list = organisation.load_or_create_feature_list(:en)
        7.times do |i|
          edition = create(:published_news_article, first_published_at: i.days.ago)
          features << create(:feature, document: edition.document, feature_list: feature_list, ordering: i)
        end

        get :show, id: organisation

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
        organisation = create(org_type)
        get :show, id: organisation
        refute_select "#featured-documents article"
      end

      view_test "#{org_type}:presents the contact details of the organisation using hcard" do
        organisation = create(org_type)
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
        get :show, id: organisation

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
            assert_select "a[href=http://pomp.gov.uk/contact]"
          end
        end
      end

      view_test "#{org_type}:show has atom feed autodiscovery link" do
        organisation = create(org_type)

        get :show, id: organisation

        assert_select_autodiscovery_link organisation_url(organisation, format: "atom")
      end

      view_test "#{org_type}:show includes a link to the atom feed and featured documents" do
        organisation = create(org_type)
        feature_list = organisation.load_or_create_feature_list(:en)
        edition = create(:published_news_article, first_published_at: 1.days.ago)
        create(:feature, document: edition.document, feature_list: feature_list, ordering: 1)
        get :show, id: organisation

        assert_select "a.feed[href=?]", organisation_url(organisation, format: :atom)
      end

      view_test "#{org_type}:shows 3 most recently published editions associated with organisation when featuring a doc" do
        # different edition types sort on different attributes
        editions = [create(:published_policy, first_published_at: 1.days.ago),
                  create(:published_publication, publication_date: 2.days.ago),
                  create(:published_consultation, first_published_at: 3.days.ago),
                  create(:published_speech, first_published_at: 4.days.ago)]

        organisation = create(org_type, editions: editions)

        feature_list = create(:feature_list, featurable: organisation, locale: :en)
        create(:feature, feature_list: feature_list, document: editions[0].document)

        get :show, id: organisation

        editions[0,3].each do |edition|
          assert_select_prefix_object edition, :recent
        end
        refute_select_prefix_object editions[3], :recent
      end

      view_test "#{org_type}:should not show most recently published editions when there are none" do
        organisation = create(org_type, editions: [])
        get :show, id: organisation

        refute_select "h1", text: "Recently updated"
      end

      view_test "#{org_type}:should show list of links to social media accounts" do
        twitter = create(:social_media_service, name: "Twitter")
        flickr = create(:social_media_service, name: "Flickr")
        twitter_account = create(:social_media_account, social_media_service: twitter, url: "https://twitter.com/#!/bisgovuk")
        flickr_account = create(:social_media_account, social_media_service: flickr, url: "http://www.flickr.com/photos/bisgovuk")
        organisation = create(org_type, social_media_accounts: [twitter_account, flickr_account])

        get :show, id: organisation

        assert_select_object twitter_account
        assert_select_object flickr_account
      end

      view_test "#{org_type}:should not show list of links to social media accounts if there are none" do
        organisation = create(org_type, social_media_accounts: [])

        get :show, id: organisation

        refute_select ".social-media-accounts"
      end

      view_test "#{org_type}:show has a link to govdelivery if one exists and featured documents" do
        organisation = create(org_type)
        feature_list = organisation.load_or_create_feature_list(:en)
        edition = create(:published_news_article, first_published_at: 1.days.ago)
        create(:feature, document: edition.document, feature_list: feature_list, ordering: 1)

        get :show, id: organisation

        assert_select ".govdelivery[href='#{email_signups_path(organisation: organisation.slug)}']"
      end
    end
  end
end
