require 'test_helper'

class Api::ResponderTest < ActiveSupport::TestCase
  test 'to_json asks the resource to become json' do
    resource = mock
    resource.expects(:as_json).returns('meh' => 1)
    responder = make_responder_for_resource(resource)

    responder.to_json
  end

  test 'to_json sends the json-ified resource to display' do
    resource = { meh: 1 }
    responder = make_responder_for_resource(resource)

    responder.to_json
    assert_equal 1, responder.displayed_json['meh']
  end

  test 'to_json injects the _response_info into the json-ified resource it sends to display' do
    resource = {}
    responder = make_responder_for_resource(resource)

    responder.to_json
    assert responder.displayed_json.has_key?(:_response_info)
  end

  test 'the _response_info in the json includes the status' do
    resource = {}
    responder = make_responder_for_resource(resource)

    responder.to_json
    assert_equal 'ok', responder.displayed_json[:_response_info][:status]
  end

  test 'the _response_info in the json includes the status from the options' do
    resource = {}
    responder = make_responder_for_resource(resource, status: :not_found)

    responder.to_json
    assert_equal 'not found', responder.displayed_json[:_response_info][:status]
  end

  test 'the _response_info in the json has no links if none are specified' do
    resource = {}
    responder = make_responder_for_resource(resource)

    responder.to_json
    response_info = responder.displayed_json[:_response_info]
    refute response_info.has_key?(:links)
  end

  test 'providing links in the options will include them in the _response_info json' do
    resource = {}
    responder = make_responder_for_resource(resource, links: [['http://example.com/woo', { 'rel' => 'self' }]])

    responder.to_json
    response_info = responder.displayed_json[:_response_info]
    assert response_info.has_key?(:links)
    assert_equal 1, response_info[:links].size
    assert_equal %i[href rel], response_info[:links].first.keys.sort
    assert_equal 'http://example.com/woo', response_info[:links].first[:href]
    assert_equal 'self', response_info[:links].first[:rel]
  end

  test 'providing links in the options sets the Link http header with them' do
    resource = {}
    responder = make_responder_for_resource(resource, links: [['http://example.com/woo', { 'rel' => 'self' }]])
    headers = {}
    responder.controller.expects(:headers).returns(headers)
    responder.to_json

    assert headers.has_key?('Link')
    assert_equal '<http://example.com/woo>; rel="self"', headers['Link']
  end

  test 'providing links via the resource will include them in the _response_info json' do
    resource = stub
    resource.stubs(:as_json).returns({})
    resource.stubs(:links).returns([['http://example.com/woo', { 'rel' => 'self' }]])
    responder = make_responder_for_resource(resource)

    responder.to_json
    response_info = responder.displayed_json[:_response_info]
    assert response_info.has_key?(:links)
    assert_equal 1, response_info[:links].size
    assert_equal %i[href rel], response_info[:links].first.keys.sort
    assert_equal 'http://example.com/woo', response_info[:links].first[:href]
    assert_equal 'self', response_info[:links].first[:rel]
  end

  test 'providing links via the resource sets the Link http header with them' do
    resource = stub
    resource.stubs(:as_json).returns({})
    resource.stubs(:links).returns([['http://example.com/woo', { 'rel' => 'self' }]])
    responder = make_responder_for_resource(resource)
    headers = {}
    responder.controller.expects(:headers).returns(headers)
    responder.to_json

    assert headers.has_key?('Link')
    assert_equal '<http://example.com/woo>; rel="self"', headers['Link']
  end

  test 'providing links via the resource and options will include them both in the _response_info json' do
    resource = stub
    resource.stubs(:as_json).returns({})
    resource.stubs(:links).returns([['http://example.com/woo', { 'rel' => 'self' }]])
    responder = make_responder_for_resource(resource, links: [['http://example.com/foo', { 'rel' => 'next' }]])

    responder.to_json
    response_info = responder.displayed_json[:_response_info]
    assert response_info.has_key?(:links)
    assert_equal 2, response_info[:links].size

    assert_equal %i[href rel], response_info[:links][0].keys.sort
    assert_equal 'http://example.com/woo', response_info[:links][0][:href]
    assert_equal 'self', response_info[:links][0][:rel]

    assert_equal %i[href rel], response_info[:links][1].keys.sort
    assert_equal 'http://example.com/foo', response_info[:links][1][:href]
    assert_equal 'next', response_info[:links][1][:rel]
  end

  test 'providing links via the resource and options sets the Link http header with them all' do
    resource = stub
    resource.stubs(:as_json).returns({})
    resource.stubs(:links).returns([['http://example.com/woo', { 'rel' => 'self' }]])
    responder = make_responder_for_resource(resource, links: [['http://example.com/foo', { 'rel' => 'next' }]])
    headers = {}
    responder.controller.expects(:headers).returns(headers)
    responder.to_json

    assert headers.has_key?('Link')
    assert_equal '<http://example.com/woo>; rel="self", <http://example.com/foo>; rel="next"', headers['Link']
  end

  test 'providing the same links via the resource and options will not create duplicates in the json' do
    resource = stub
    resource.stubs(:as_json).returns({})
    resource.stubs(:links).returns([['http://example.com/woo', { 'rel' => 'self' }]])
    responder = make_responder_for_resource(resource, links: [['http://example.com/woo', { 'rel' => 'self' }]])

    responder.to_json
    response_info = responder.displayed_json[:_response_info]
    assert response_info.has_key?(:links)
    assert_equal 1, response_info[:links].size

    assert_equal %i[href rel], response_info[:links][0].keys.sort
    assert_equal 'http://example.com/woo', response_info[:links][0][:href]
    assert_equal 'self', response_info[:links][0][:rel]
  end

  test 'providing the same links via the resource and options will not create duplicates in the Link header' do
    resource = stub
    resource.stubs(:as_json).returns({})
    resource.stubs(:links).returns([['http://example.com/woo', { 'rel' => 'self' }]])
    responder = make_responder_for_resource(resource, links: [['http://example.com/woo', { 'rel' => 'self' }]])
    headers = {}
    responder.controller.expects(:headers).returns(headers)
    responder.to_json

    assert headers.has_key?('Link')
    assert_equal '<http://example.com/woo>; rel="self"', headers['Link']
  end

  def make_responder_for_resource(resource, options = {})
    controller = mock
    controller.instance_eval do
      def render(options)
        @rendered_json = options[:json]
      end

      def rendered_json
        @rendered_json
      end
    end

    request = mock
    controller.stubs(:request).returns(request)
    controller.stubs(:formats).returns([:json])
    controller.stubs(:headers).returns({})
    r = Api::Responder.new(controller, [resource], options)
    def r.displayed_json
      controller.rendered_json
    end
    r
  end
end
