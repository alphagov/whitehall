module ModelStubbingHelpers
  def stub_record(type, options = {})
    result = build(type, options)
    result.stubs(:id).returns(next_record_id)
    result.stubs(:new_record?).returns(false)
    result
  end

  def next_record_id
    @next_id ||= 0
    @next_id += 1
  end
end