if defined? Rails
  # if we've already loaded rails, no point jumping through hoops to avoid it
  require 'test_helper'

  module AuthorityTestHelper
    def normal_edition(user=nil)
      ne = FactoryGirl.build(:edition)
      ne.stubs(:creator).returns(user)
      ne
    end
    def force_published_edition(user)
      fpe = FactoryGirl.build(:published_edition, force_published: true)
      fpe.stubs(:published_by).returns(user)
      fpe
    end
    def limited_edition(orgs)
      le = FactoryGirl.build(:edition, access_limited: true)
      le.stubs(:organisations).returns(Array.wrap(orgs))
      le
    end

    def normal_fatality_notice(user=nil)
      fn = FactoryGirl.build(:fatality_notice)
      fn.stubs(:creator).returns(user)
      fn
    end

    def force_published_fatality_notice(user)
      fpfn = FactoryGirl.build(:published_fatality_notice, force_published: true)
      fpfn.stubs(:published_by).returns(user)
      fpfn
    end

    def limited_fatality_notice(orgs)
      lfn = FactoryGirl.build(:fatality_notice, access_limited: true)
      lfn.stubs(:organisations).returns(Array.wrap(orgs))
      lfn
    end

    def normal_world_location_news(user=nil)
      wln = FactoryGirl.build(:world_location_news)
      wln.stubs(:creator).returns(user)
      wln
    end

    def force_published_world_location_news(user)
      fpwln = FactoryGirl.build(:published_world_location_news, force_published: true)
      fpwln.stubs(:published_by).returns(user)
      fpwln
    end

    def limited_world_location_news(orgs)
      lwln = FactoryGirl.build(:world_location_news, access_limited: true)
      lwln.stubs(:organisations).returns(Array.wrap(orgs))
      lwln
    end
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
    def normal_edition(user=nil)
      Edition.new(user)
    end

    def force_published_edition(user)
      Edition.new(nil, true, user)
    end

    def limited_edition(orgs)
      e = LimitedEdition.new
      e.organisations = (orgs || [])
      e
    end

    def normal_fatality_notice(user=nil)
      FatalityNotice.new(user)
    end

    def force_published_fatality_notice(user)
      FatalityNotice.new(nil, true, user)
    end

    def limited_fatality_notice(orgs)
      lfn = LimitedFatalityNotice.new
      lfn.organisations = (orgs || [])
      lfn
    end

    def normal_world_location_news(user=nil)
      WorldLocationNewsArticle.new(user)
    end

    def force_published_world_location_news(user)
      WorldLocationNewsArticle.new(nil, true, user)
    end

    def limited_world_location_news(orgs)
      lfn = LimitedWorldLocationNewsArticle.new
      lfn.organisations = (orgs || [])
      lfn
    end
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
