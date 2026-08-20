require 'test_helper'
require 'public_http_fetcher'

module ScriptChecking
  class LinkCheckerSsrfTest < ::ActiveSupport::TestCase
    test 'resolve returns the final URL from the protected fetcher' do
      url = 'https://bit.ly/example'
      response = stub
      response.stubs(:[]).with('content-type').returns('text/plain')
      result = PublicHttpFetcher::FetchResult.new(response:, url: 'https://final.example/path')
      PublicHttpFetcher.expects(:get_response).with(url).returns(result)

      assert_equal 'https://final.example/path', LinkChecker.resolve(url)
    end

    test 'resolve preserves meta refresh handling' do
      url = 'https://www.baidu.com/link?url=example'
      response = stub(body: '<meta http-equiv="refresh" content="0;URL=https://final.example/meta">')
      response.stubs(:[]).with('content-type').returns('text/html')
      result = PublicHttpFetcher::FetchResult.new(response:, url: 'https://intermediate.example/path')
      PublicHttpFetcher.expects(:get_response).with(url).returns(result)

      assert_equal 'https://final.example/meta', LinkChecker.resolve(url)
    end

    test 'resolve returns the original URL when the protected fetcher rejects a destination' do
      url = 'https://bit.ly/example'
      PublicHttpFetcher.expects(:get_response).with(url).raises(PublicHttpFetcher::FetchError, 'private address')

      assert_equal url, LinkChecker.resolve(url)
    end
  end
end
