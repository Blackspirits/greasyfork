require 'test_helper'

class ReportMessagePrivacyTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @message = messages(:geoff_and_junior_1)
    @report = Report.create!(
      item: @message,
      reporter: users(:junior),
      reason: Report::REASON_SPAM,
      explanation_markup: 'markdown'
    )
  end

  test 'message report is not public' do
    get report_path(@report)

    assert_response :not_found
    assert_not_includes response.body, @message.content
  end

  test 'unrelated signed-in user cannot view message report' do
    sign_in users(:one)

    get report_path(@report)

    assert_response :not_found
    assert_not_includes response.body, @message.content
  end

  test 'conversation participant can view message report' do
    sign_in users(:geoff)

    get report_path(@report)

    assert_response :success
    assert_includes response.body, @message.content
  end
end
