class StandardEditionMigrator::LegacyPresenter
  def initialize(_legacy_record, update_type: nil, title: nil); end

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
