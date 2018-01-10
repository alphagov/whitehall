module AdminControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_social_media_management_for(type)
      target_class = class_for(type)

      test "should display social media account fields for new #{type}" do
        get :new
        assert_kind_of SocialMediaAccount, assigns(type).social_media_accounts.first
      end

      test "creating should be able to create a new social media account for the #{type}" do
        social_media_service = create(:social_media_service)

        post :create, params: {
          type => attributes_for(type).merge(
            social_media_accounts_attributes: {
              "0" =>
              {
                social_media_service_id: social_media_service.id,
                url: "https://twitter.com/#!/bisgovuk"
              }
            }
          )
        }

        assert object = target_class.last
        assert social_media_account = object.social_media_accounts.last
        assert_equal social_media_service, social_media_account.social_media_service
        assert_equal "https://twitter.com/#!/bisgovuk", social_media_account.url
      end

      test "creating with invalid data should build another social media account" do
        post :create, params: { type => attributes_for(type).merge(name: '') }
        assert_kind_of SocialMediaAccount, assigns(type).social_media_accounts.first
      end

      test "creating ignores blank social media accounts" do
        post :create, params: {
          type => attributes_for(type).merge(
            social_media_accounts_attributes: {
              "0" => {
                social_media_service_id: "", url: ""
              }
            }
          )
        }

        assert created_object = target_class.last
        assert_equal 0, created_object.social_media_accounts.size
      end

      test "editing should display existing social media accounts" do
        twitter = create(:social_media_service, name: "Twitter")
        account = create(:social_media_account, social_media_service: twitter, url: "http://twitter.com/foo")
        object = create(type, social_media_accounts: [account])

        get :edit, params: { id: object }

        assert assigns(type).social_media_accounts.all? { |o| o.is_a? SocialMediaAccount }
        assert assigns(type).social_media_accounts.last.new_record?
      end

      test "updating should create new social media account" do
        object = create(type)
        social_media_service = create(:social_media_service)

        put :update, params: { id: object, type => object.attributes.merge(
          social_media_accounts_attributes: { "0" => {
          social_media_service_id: social_media_service.id,
          url: "https://twitter.com/#!/bisgovuk"
        } }
        ) }

        assert social_media_account = object.social_media_accounts.last
        assert_equal social_media_service, social_media_account.social_media_service
        assert_equal "https://twitter.com/#!/bisgovuk", social_media_account.url
      end

      test "updating should destroy existing social media account if all its field are blank" do
        attributes = attributes_for(type)
        object = create(type, attributes)
        account = create(:social_media_account, socialable: object)

        put :update, params: { id: object, type => attributes.merge(
          social_media_accounts_attributes: { "0" => {
          id: account.id,
          social_media_service_id: "",
          url: ""
        } }
        ) }

        assert_equal 0, object.social_media_accounts.count
      end

      test "updating with blank social media account fields should not create new account" do
        object = create(type)

        put :update, params: { id: object, type => object.attributes.merge(
          social_media_accounts_attributes: { "0" => {
          social_media_service_id: "",
          url: ""
        } }
        ) }

        assert object.social_media_accounts.empty?
      end

      test "updating with invalid data should still display blank social media account fields" do
        object = create(type)

        put :update, params: { id: object, type => object.attributes.merge(name: "") }

        assert_select "select[name='#{type}[social_media_accounts_attributes][0][social_media_service_id]']" do
          refute_select "option[selected='selected']"
          assert_select "option", text: ""
        end
        assert_select "input[type=text][name='#{type}[social_media_accounts_attributes][0][url]']"
      end
    end

    def should_allow_contact_management_for(type)
      target_class = class_for(type)

      test "creates contact information" do
        attributes = attributes_for(type)

        create(:topic)

        post :create, params: {
          type => attributes.merge(
            contacts_attributes: [
              {
                description: "Enquiries",
                contact_numbers_attributes: [
                  {
                    label: "Fax",
                    number: "020712435678"
                  }
                ]
              }
            ],
          )
        }

        assert object = target_class.last
        assert_equal 1, object.contacts.count
        assert_equal "Enquiries", object.contacts[0].description
        assert_equal 1, object.contacts[0].contact_numbers.count
        assert_equal "Fax", object.contacts[0].contact_numbers[0].label
        assert_equal "020712435678", object.contacts[0].contact_numbers[0].number
      end

      test "creating with blank numbers ignores blank numbers" do
        post :create, params: {
          type => attributes_for(type).merge(
            contacts_attributes: {
              "0" => {
                description: "Enquiries",
                contact_numbers_attributes: {
                  "0" => { label: " ", number: " " },
                  "1" => { label: " ", number: " " },
                }
              }
            }
          )
        }

        created_object = target_class.last
        assert_not_nil created_object
        assert_equal 0, created_object.contacts.first.contact_numbers.size
      end

      test "updating with an empty contact should not create that contact" do
        object = create(type)
        attributes = {
          contacts_attributes: [{ description: "", number: "" }]
        }

        put :update, params: { id: object, type => attributes }

        assert_equal 0, object.contacts.count
      end

      test "updating with blank numbers destroys those blank numbers" do
        object = create(type)
        contact = create(:contact, contactable: object)
        contact_number = create(:contact_number, contact: contact)

        put :update, params: { id: object, type => { contacts_attributes: { 0 => {
          id: contact,
          contact_numbers_attributes: {
          0 => { label: " ", number: " ", id: contact_number }
        }
        } } } }

        contact.reload
        assert_equal 0, contact.contact_numbers.count
      end
    end
  end
end
