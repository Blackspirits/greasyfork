module ConversationMessageHelper
  include UserTextHelper

  AUTOLOADING_MEDIA_ELEMENTS = %w[iframe img video].freeze

  def format_conversation_message(message, mentions: [])
    html = format_user_text(message.content, message.content_markup, mentions: mentions)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html)
    fragment.css(AUTOLOADING_MEDIA_ELEMENTS.join(',')).remove
    fragment.to_html.html_safe
  end
end
