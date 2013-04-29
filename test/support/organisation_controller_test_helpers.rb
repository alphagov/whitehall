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

      test "#{org_type}:shows primary featured editions in ordering defined by association" do
        organisation = create(org_type)
        news_article = create(:published_news_article)
        policy = create(:published_policy)
        create(:featured_edition_organisation, edition: news_article, organisation: organisation, ordering: 1)
        create(:featured_edition_organisation, edition: policy, organisation: organisation, ordering: 0)

        get :show, id: organisation

        assert_equal [policy, news_article], assigns(:featured_editions).collect(&:model)
      end

      view_test "#{org_type}:shows a maximum of 6 featured editions" do
        organisation = create(org_type)
        editions = []
        7.times do |i|
          edition = create(:published_news_article, first_published_at: i.days.ago)
          editions << create(:featured_edition_organisation, edition: edition, organisation: organisation)
        end

        get :show, id: organisation

        assert_select_object editions[0].edition do
          assert_select "img[src$='#{editions[0].image.file.url(:s630)}'][alt=?]", editions[0].alt_text
        end
        editions[1...6].each do |edition|
          assert_select_object edition.edition do
            assert_select "img[src$='#{edition.image.file.url(:s300)}'][alt=?]", edition.alt_text
          end
        end
        refute_select_object editions.last.edition
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
          street_address: "1 Smashing Place, London", postal_code: "LO1 8DN",
          contact_numbers_attributes: [
            { label: "Helpline", number: "02079460000" },
            { label: "Fax", number: "02079460001" }
          ],
          country: create(:world_location, iso2: 'GB')
        )
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

      view_test "#{org_type}:show includes a link to the atom feed" do
        organisation = create(org_type)

        get :show, id: organisation

        assert_select "a.feed[href=?]", organisation_url(organisation, format: :atom)
      end

      view_test "#{org_type}:shows 3 most recently published editions associated with organisation" do
        # different edition types sort on different attributes
        editions = [create(:published_policy, first_published_at: 1.days.ago),
                  create(:published_publication, publication_date: 2.days.ago),
                  create(:published_consultation, first_published_at: 3.days.ago),
                  create(:published_speech, delivered_on: 4.days.ago)]

        organisation = create(org_type, editions: editions)
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

      view_test "#{org_type}:show hass a link to govdelivery if one exists" do
        organisation = create(org_type)

        get :show, id: organisation

        assert_select ".govdelivery[href='#{email_signups_path(organisation: organisation.slug)}']"
      end
    end
  end
end
