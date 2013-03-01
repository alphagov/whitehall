module ModelStubbingHelpers
  def stub_record(type, options = {})
    result = build(type, options)
    result.stubs(:id).returns(next_record_id)
    result.stubs(:new_record?).returns(false)
    result.stubs(:created_at).returns(Time.zone.now) if result.respond_to?(:created_at)
    result.stubs(:updated_at).returns(Time.zone.now) if result.respond_to?(:updated_at)
    result
  end

  def stub_edition(type, options = {})
    document = stub_record(:document)
    document.stubs(:to_param).returns(document.slug)
    stub_record(type, options.merge(document: document))
  end

  def stub_translatable_record(type, options = {})
    translations = []
    Mocha::Configuration.allow(:stubbing_non_existent_method) do
      translations.stubs(
        loaded?: true,
        translated_locales: [:en]
      )
    end
    record = stub_record(type, options)
    record.stubs(:translations).returns(translations)
    record
  end

  def next_record_id
    @next_id ||= 0
    @next_id += 1
  end
end
