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
  end
end

module AuthorityTestHelper
  def enforcer_for(actor, subject)
    Whitehall::Authority::Enforcer.new(actor, subject)
  end
end
