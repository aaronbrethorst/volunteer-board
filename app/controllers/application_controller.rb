class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Search filters are read straight from params in controllers and views;
  # nested values (e.g. ?query[a]=b) would otherwise raise a 500.
  def require_string_filter_params
    unless params.values_at(:query, :discipline).all? { |value| value.nil? || value.is_a?(String) }
      head :bad_request
    end
  end
end
