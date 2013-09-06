require 'test_helper'

class FeaturePresenterTest < PresenterTestCase
  test '#public_path generates a link to a topical event if that is what has been featured' do
    te = stub_record(:topical_event)
    f = stub_record(:feature, topical_event: te, document: nil)
    fp = FeaturePresenter.new(f)

    assert_equal topical_event_path(te), fp.public_path
  end

  test '#public_path doesn\'t localize links to topical events' do
    te = stub_record(:topical_event)
    f = stub_record(:feature, topical_event: te, document: nil)
    f.stubs(:locale).returns('ar')
    fp = FeaturePresenter.new(f)

    assert_equal topical_event_path(te), fp.public_path
  end

  test '#public_path generates a localized link to the edition' do
    d = stub_record(:document)
    cs = stub_record(:case_study, document: d, create_default_organisation: false)
    d.stubs(:published_edition).returns(cs)
    f = stub_record(:feature, topical_event: nil, document: d)
    f.stubs(:locale).returns('ar')
    fp = FeaturePresenter.new(f)

    assert_equal case_study_path(d.slug, locale: 'ar'), fp.public_path
  end

  test '#public_path generates an unlocalized link to the edition if it\'s not a localizable type' do
    d = stub_record(:document)
    p = stub_record(:consultation, document: d, create_default_organisation: false, alternative_format_provider: nil)
    d.stubs(:published_edition).returns(p)
    f = stub_record(:feature, topical_event: nil, document: d)
    f.stubs(:locale).returns('ar')
    fp = FeaturePresenter.new(f)

    assert_equal consultation_path(d.slug), fp.public_path
  end

  test '#public_path respects the locale of the feature when generating localized edition links' do
    d = stub_record(:document)
    cs = stub_record(:case_study, document: d, create_default_organisation: false)
    d.stubs(:published_edition).returns(cs)
    f = stub_record(:feature, topical_event: nil, document: d)
    f.stubs(:locale).returns('ar')
    fp = FeaturePresenter.new(f)

    ::I18n.with_locale 'fr' do
      assert_equal case_study_path(d.slug, locale: 'ar'), fp.public_path
    end
  end

  test '#public_path forces the global locale to english when generating edition links for a non localizable types' do
    d = stub_record(:document)
    p = stub_record(:consultation, document: d, create_default_organisation: false, alternative_format_provider: nil)
    d.stubs(:published_edition).returns(p)
    f = stub_record(:feature, topical_event: nil, document: d)
    f.stubs(:locale).returns('ar')
    fp = FeaturePresenter.new(f)

    ::I18n.with_locale 'fr' do
      assert_equal consultation_path(d.slug), fp.public_path
      refute_match(/locale=fr/, fp.public_path)
      refute_match(/\.fr/, fp.public_path)
    end
  end
end
