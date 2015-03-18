require 'test_helper'

class PublishingApiPresenters::UnpublishingTest < ActiveSupport::TestCase

  test '#as_json returns a valid representation of an Unpublishing' do
    unpublishing = create(:unpublishing)
    edition      = unpublishing.edition
    public_path  = unpublishing.document_path
    expected_hash = {
      content_id: edition.content_id,
      title: edition.title,
      description: edition.summary,
      format: 'unpublishing',
      locale: 'en',
      need_ids: [],
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      public_updated_at: edition.public_timestamp,
      update_type: 'major',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        explanation: nil,
        unpublished_at: unpublishing.created_at,
        alternative_url: nil
      }
    }

    presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'unpublishing')
  end

  test '#as_json allows update_type to be overridden' do
    presenter = PublishingApiPresenters::Unpublishing.new(create(:unpublishing), update_type: 'republish')

    assert_equal 'republish', presenter.as_json[:update_type]
    assert_valid_against_schema(presenter.as_json, 'unpublishing')
  end

  test '#as_json returns a valid representation of an Unpublishing with compiled govspeak explanation' do
    unpublishing = create(:unpublishing, explanation: 'Some explanation')
    edition      = unpublishing.edition
    public_path  = unpublishing.document_path
    expected_details_hash = {
      explanation: '<div class="govspeak"><p>Some explanation</p></div>',
      unpublished_at: unpublishing.created_at,
      alternative_url: nil
    }

    presented_hash = PublishingApiPresenters::Unpublishing.new(unpublishing).as_json

    assert_valid_against_schema(presented_hash, 'unpublishing')
    # We test for HTML equivalence rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_details_hash.delete(:explanation),
      presented_hash[:details].delete(:explanation)
    assert_equal expected_details_hash, presented_hash[:details]
  end

  test '#as_json returns a valid representation of an Unpublishing with an alternative URL' do
    alternative_url = Whitehall.public_root + '/government/some/page'
    unpublishing    = create(:unpublishing, alternative_url: alternative_url)
    edition         = unpublishing.edition
    public_path     = Whitehall.url_maker.public_document_path(edition)
    expected_details_hash = {
      explanation: nil,
      unpublished_at: unpublishing.created_at,
      alternative_url: alternative_url
    }

    presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)

    assert_equal expected_details_hash, presenter.as_json[:details]
    assert_valid_against_schema(presenter.as_json, 'unpublishing')
  end

  test '#as_json handles Unpublishings for translated editions' do
    unpublishing = create(:unpublishing)
    edition      = unpublishing.edition

    french_base_path = Whitehall.url_maker.public_document_path(edition, locale: :fr)

    I18n.with_locale(:fr) do
      edition.title = 'French title'
      edition.save!

      presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)

      assert_equal french_base_path, presenter.as_json[:routes].first[:path]
      assert_valid_against_schema(presenter.as_json, 'unpublishing')
    end
  end

  test '#as_json handles an Unpublishing with a deleted edition' do
    unpublishing = create(:unpublishing)
    edition      = unpublishing.edition
    public_path  = unpublishing.document_path
    expected_hash = {
      content_id: edition.content_id,
      title: edition.title,
      description: edition.summary,
      format: 'unpublishing',
      locale: 'en',
      need_ids: [],
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      public_updated_at: edition.public_timestamp,
      update_type: 'major',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        explanation: nil,
        unpublished_at: unpublishing.created_at,
        alternative_url: nil
      }
    }

    EditionDeleter.new(edition).perform!

    presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'unpublishing')
  end

  test '#as_json handles an Unpublishing with a deleted translated edition' do
    unpublishing      = create(:unpublishing)
    edition           = unpublishing.edition
    french_base_path  = Whitehall.url_maker.public_document_path(edition, locale: :fr)

    I18n.with_locale(:fr) do
      edition.title = 'French title'
      edition.save!(validate: false)
    end

    EditionDeleter.new(edition).perform!
    unpublishing.reload

    I18n.with_locale(:fr) do
      presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)

      assert_equal french_base_path, presenter.as_json[:routes].first[:path]
      assert_equal 'fr', presenter.as_json[:locale]
      assert_valid_against_schema(presenter.as_json, 'unpublishing')
    end
  end

  test '#as_json returns a redirect representation for Unpublishings that are set to auto-redirect' do
    unpublishing     = create(:redirect_unpublishing)
    public_path      = unpublishing.document_path
    alternative_path = URI.parse(unpublishing.alternative_url).path
    expected_hash    = {
      format: 'redirect',
      publishing_app: 'whitehall',
      update_type: 'major',
      redirects: [
        { path: public_path, type: 'exact', destination: alternative_path }
      ]
    }

    presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'redirect')
  end

  test '#as_json returns a redirect representation for consolidated Unpublishings' do
    alternative_path = '/government/some/page'
    unpublishing     = create(:consolidated_unpublishing)
    public_path      = unpublishing.document_path
    alternative_path = URI.parse(unpublishing.alternative_url).path
    expected_hash    = {
      format: 'redirect',
      publishing_app: 'whitehall',
      update_type: 'major',
      redirects: [
        { path: public_path, type: 'exact', destination: alternative_path }
      ]
    }

    presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)

    assert_equal expected_hash, presenter.as_json
    assert_valid_against_schema(presenter.as_json, 'redirect')
  end

  test 'redirect representations can contain query paramters and anchor tags' do
    alternative_path = '/page?param=1#subheading'
    unpublishing     = create(:redirect_unpublishing,
      alternative_url: Whitehall.public_root + alternative_path)

    presenter = PublishingApiPresenters::Unpublishing.new(unpublishing)
    presented_hash = presenter.as_json

    assert_equal alternative_path, presented_hash[:redirects][0][:destination]
  end
end
