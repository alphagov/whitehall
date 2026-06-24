class StandardEditionMigrator::HardcodedPresenter
  def initialize(record); end

  def content
    {
      "body": "OLD PAYLOAD",
      "some_old_field": "some old value",
    }
  end

  def links
    {
      "old_link": "old link",
    }
  end
end
