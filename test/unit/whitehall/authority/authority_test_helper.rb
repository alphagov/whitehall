if defined? Rails
  # if we've already loaded rails, no point jumping through hoops to avoid it
  require 'test_helper'

  module AuthorityTestHelper
    def self.define_edition_factory_methods(edition_type)
      define_method("normal_#{edition_type}") do |user = nil|
        ne = FactoryGirl.build(edition_type)
        ne.stubs(:creator).returns(user)
        ne
      end
      define_method("force_published_#{edition_type}") do |user|
        fpe = FactoryGirl.build(:"published_#{edition_type}", force_published: true)
        fpe.stubs(:published_by).returns(user)
        fpe
      end
      define_method("limited_#{edition_type}") do |orgs|
        le = FactoryGirl.build(edition_type, access_limited: true)
        le.stubs(:organisations).returns(Array.wrap(orgs))
        le
      end
    end

    define_edition_factory_methods :edition
    define_edition_factory_methods :fatality_notice
    define_edition_factory_methods :world_location_news_article
  end
else
  # otherwise use the fast_test_helper and fake things out a bit
  require 'fast_test_helper'
  require 'whitehall/authority'

  class Edition < Struct.new(:creator, :force_published, :published_by);
    def force_published?
      !!@force_published
    end
    def access_limited?
      false
    end
    def organisations
      []
    end
  end

  class LimitedEdition < Edition
    def access_limited?
      true
    end
    def organisations=(orgs)
      @orgs = orgs
    end
    def organisations
      @orgs
    end
  end

  class FatalityNotice < Edition
  end
  class LimitedFatalityNotice < FatalityNotice
    def access_limited?
      true
    end
    def organisations=(orgs)
      @orgs = orgs
    end
    def organisations
      @orgs
    end
  end

  class WorldLocationNewsArticle < Edition
  end
  class LimitedWorldLocationNewsArticle < WorldLocationNewsArticle
    def access_limited?
      true
    end
    def organisations=(orgs)
      @orgs = orgs
    end
    def organisations
      @orgs
    end
  end

  class Document; end

  module AuthorityTestHelper
    def self.get_class_from_type(edition_type)
      class_name = edition_type.to_s.gsub('_',' ').split().map(&:capitalize).join
      Object.const_get(class_name)
    end

    def self.define_edition_factory_methods(edition_type)
      define_method("normal_#{edition_type}") do |user = nil|
        AuthorityTestHelper.get_class_from_type(edition_type).new(user)
      end
      define_method("force_published_#{edition_type}") do |user|
        AuthorityTestHelper.get_class_from_type(edition_type).new(nil, true, user)
      end
      define_method("limited_#{edition_type}") do |orgs|
        e = AuthorityTestHelper.get_class_from_type("limited_#{edition_type}").new
        e.organisations = (orgs || [])
        e
      end
    end

    define_edition_factory_methods :edition
    define_edition_factory_methods :fatality_notice
    define_edition_factory_methods :world_location_news_article
  end
end

module AuthorityTestHelper
  def enforcer_for(actor, subject)
    Whitehall::Authority::Enforcer.new(actor, subject)
  end

  def with_locations(edition, world_locations)
    edition.stubs(:world_locations).returns(world_locations)
    edition
  end
end
