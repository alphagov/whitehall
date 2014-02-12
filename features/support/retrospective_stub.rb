class RetrospectiveStub
  attr_reader :stubs, :calls

  class UnsatisfiedAssertion < StandardError; end

  def initialize
    @stubs = []
    @calls = []
  end

  def method_missing(method, *args)
    calls << { method: method, args: args }

    stub = get_matching_stub(method, args)

    if stub.nil?
      raise NoMethodError.new("Unexpected call - :#{method} with #{args.inspect}")
    else
      if stub[:returns].is_a? Proc
        stub[:returns].call(*args)
      else
        stub[:returns]
      end
    end
  end

  def stub(method, opts = {})
    stubs << {
      method: method,
      with: opts[:with],
      returns: opts[:returns]
    }
  end

  def assert_method_called(method, opts = {})
    raise UnsatisfiedAssertion.new("Expected :#{method} to have been called, but wasn't\n\nCalls: \n#{inspect_calls}") unless @calls.any? { | call |
      call[:method] == method
    }

    if opts[:with].present?
      raise UnsatisfiedAssertion.new("Expected :#{method} to have been called #{inspect_args opts[:with]}, but wasn't\n\nCalls: \n#{inspect_calls}") unless @calls.any? { | call |
        call[:method] == method && (
          opts[:with].is_a?(Proc) ? opts[:with].call(*call[:args]) : opts[:with] == call[:args]
        )
      }
    end
  end

  def refute_method_called(method, opts = {})
    if opts[:with].present?
      raise UnsatisfiedAssertion.new("Expected :#{method} not to have been called #{inspect_args opts[:with]}\n\nCalls: \n#{inspect_calls}") if @calls.any? { | call |
        call[:method] == method && (
          opts[:with].is_a?(Proc) ? opts[:with].call(*call[:args]) : opts[:with] == call[:args]
        )
      }
    else
      raise UnsatisfiedAssertion.new("Expected :#{method} not to have been called\n\nCalls: \n#{inspect_calls}") if @calls.any? { | call |
        call[:method] == method
      }
    end
  end

private
  def get_matching_stub(method, args)
    stub = stubs.find { |stub|
      stub[:method] == method && (
        stub[:with].is_a?(Proc) ? stub[:with].call(args) : (stub[:with] == args)
      )
    }
    if stub.nil?
      stub = stubs.find { |stub|
        stub[:method] == method
      }
    end
    stub
  end

  def inspect_calls
    calls.map { |call|
      ":#{call[:method]}, Arguments: #{call[:args]}"
    }.join "\n"
  end

  def inspect_args(args)
    if args.is_a? Proc
      return "matching block: #{args.source}"
    else
      "with: #{args.inspect}"
    end
  end
end
