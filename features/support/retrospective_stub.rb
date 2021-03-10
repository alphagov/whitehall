class RetrospectiveStub
  attr_reader :stubs, :calls

  class UnsatisfiedAssertion < StandardError; end

  def initialize
    @stubs = []
    @calls = []
  end

  # rubocop:disable Style/MissingRespondToMissing
  def method_missing(method, *args)
    calls << { method: method, args: args }

    stub = get_matching_stub(method, args)

    if stub.nil?
      raise NoMethodError, "Unexpected call - :#{method} with #{args.inspect}"
    elsif stub[:returns].is_a? Proc
      stub[:returns].call(*args)
    else
      stub[:returns]
    end
  end
  # rubocop:enable Style/MissingRespondToMissing

  def stub(method, opts = {})
    stubs << {
      method: method,
      with: opts[:with],
      returns: opts[:returns],
    }
  end

  def assert_method_called(method, opts = {})
    raise UnsatisfiedAssertion, "Expected :#{method} to have been called, but wasn't\n\nCalls: \n#{inspect_calls}" unless @calls.any? do |call|
      call[:method] == method
    end

    if opts[:with].present? && @calls.none? do |call|
         call[:method] == method && (
           opts[:with].is_a?(Proc) ? opts[:with].call(*call[:args]) : opts[:with] == call[:args]
         )
       end
      raise UnsatisfiedAssertion, "Expected :#{method} to have been called #{inspect_args opts[:with]}, but wasn't\n\nCalls: \n#{inspect_calls}"
    end
  end

  def refute_method_called(method, opts = {})
    if opts[:with].present?
      raise UnsatisfiedAssertion, "Expected :#{method} not to have been called #{inspect_args opts[:with]}\n\nCalls: \n#{inspect_calls}" if @calls.any? do |call|
        call[:method] == method && (
          opts[:with].is_a?(Proc) ? opts[:with].call(*call[:args]) : opts[:with] == call[:args]
        )
      end
    elsif @calls.any? { |call| call[:method] == method }
      raise UnsatisfiedAssertion, "Expected :#{method} not to have been called\n\nCalls: \n#{inspect_calls}"
    end
  end

private

  def get_matching_stub(method, args)
    matching_stub = stubs.find do |stub|
      stub[:method] == method && (
        stub[:with].is_a?(Proc) ? stub[:with].call(args) : (stub[:with] == args)
      )
    end

    if matching_stub.nil?
      matching_stub = stubs.find { |stub| stub[:method] == method }
    end

    matching_stub
  end

  def inspect_calls
    calls.map { |call|
      ":#{call[:method]}, Arguments: #{call[:args]}"
    }.join "\n"
  end

  def inspect_args(args)
    if args.is_a? Proc
      "matching block: #{args.source}"
    else
      "with: #{args.inspect}"
    end
  end
end
