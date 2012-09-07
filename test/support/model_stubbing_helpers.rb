module ModelStubbingHelpers
  def stub_record(type, options = {})
    result = build(type, options)
    result.stubs(:id).returns(next_record_id)
    result.stubs(:new_record?).returns(false)
    result
  end

  def stub_document(type, options = {})
    document = stub_record(:document)
    document.stubs(:to_param).returns(document.slug)
    stub_record(type, options.merge(document: document))
  end

  def next_record_id
    @next_id ||= 0
    @next_id += 1
  end
end