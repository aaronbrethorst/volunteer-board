module ApplicationHelper
  include Pagy::Method

  # Returns a parsed URI if the URL has an http(s) scheme, nil otherwise.
  def safe_external_url(url)
    return nil if url.blank?
    uri = URI.parse(url)
    uri if uri.scheme&.match?(/\Ahttps?\z/)
  rescue URI::InvalidURIError
    nil
  end
end
