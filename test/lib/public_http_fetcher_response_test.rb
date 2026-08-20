require 'test_helper'
require 'public_http_fetcher'

class PublicHttpFetcherResponseTest < ActiveSupport::TestCase
  test 'can return an unfollowed redirect response safely' do
    response = stub(code: '302')
    SsrfFilter.expects(:get).with do |url, options|
      url == 'https://source.example/start' &&
        options[:scheme_whitelist] == ['https'] &&
        options[:http_options] == { read_timeout: 10 } &&
        options[:max_redirects] == 0 &&
        options[:allow_unfollowed_redirects] == true
    end.returns(response)

    assert_same response, PublicHttpFetcher.response('https://source.example/start', max_redirects: 0, allow_unfollowed_redirects: true)
  end
end
