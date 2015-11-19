require "test_helper"

class PublishStaticPagesTest < ActiveSupport::TestCase
  test 'sends static pages to rummager' do
    Whitehall::FakeRummageableIndex.any_instance.expects(:add).twice.with(kind_of(Hash))

    PublishStaticPages.new.publish
  end
end
