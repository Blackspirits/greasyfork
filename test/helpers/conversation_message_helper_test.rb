require 'test_helper'

class ConversationMessageHelperTest < ActionView::TestCase
  test 'format_conversation_message removes autoloading media from html' do
    message = Message.new(
      content: <<~HTML,
        <p>keep me</p>
        <img src="https://tracker.example/pixel.png" alt="pixel">
        <video src="https://tracker.example/video.mp4"></video>
        <iframe src="https://www.youtube.com/embed/test"></iframe>
      HTML
      content_markup: 'html'
    )

    rendered = format_conversation_message(message)

    assert_includes rendered, 'keep me'
    refute_match(/<(?:iframe|img|video)\b/i, rendered)
  end

  test 'format_conversation_message removes markdown images' do
    message = Message.new(
      content: 'before ![pixel](https://tracker.example/pixel.png) after',
      content_markup: 'markdown'
    )

    rendered = format_conversation_message(message)

    assert_includes rendered, 'before'
    assert_includes rendered, 'after'
    refute_match(/<img\b/i, rendered)
  end
end
