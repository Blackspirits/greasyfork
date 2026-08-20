require 'test_helper'

module ScriptChecking
  class LinkCheckerSsrfTest < ::ActiveSupport::TestCase
    test 'resolves relative redirects through the safe fetcher' do
      redirect = stub
      redirect.stubs(:[]).with('location').returns('/final')
      final = stub
      final.stubs(:[]).with('location').returns(nil)
      final.stubs(:[]).with('content-type').returns(nil)

      PublicHttpFetcher.expects(:response)
                       .with('https://short.example/start', max_redirects: 0, allow_unfollowed_redirects: true)
                       .returns(redirect)
      PublicHttpFetcher.expects(:response)
                       .with('https://short.example/final', max_redirects: 0, allow_unfollowed_redirects: true)
                       .returns(final)

      assert_equal 'https://short.example/final', ScriptChecking::LinkChecker.resolve('https://short.example/start')
    end

    test 'revalidates a private redirect target before fetching it' do
      redirect = stub
      redirect.stubs(:[]).with('location').returns('http://127.0.0.1/private')

      PublicHttpFetcher.expects(:response)
                       .with('https://short.example/start', max_redirects: 0, allow_unfollowed_redirects: true)
                       .returns(redirect)
      PublicHttpFetcher.expects(:response)
                       .with('http://127.0.0.1/private', max_redirects: 0, allow_unfollowed_redirects: true)
                       .raises(PublicHttpFetcher::FetchError, 'private address')

      assert_equal 'http://127.0.0.1/private', ScriptChecking::LinkChecker.resolve('https://short.example/start')
    end
  end
end
