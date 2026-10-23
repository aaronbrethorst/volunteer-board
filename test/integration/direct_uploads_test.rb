require "test_helper"

class DirectUploadsTest < ActionDispatch::IntegrationTest
  setup do
    @blob_params = {
      blob: { filename: "logo.png", byte_size: 4, checksum: Digest::MD5.base64digest("test"), content_type: "image/png" }
    }
  end

  test "unauthenticated direct upload is rejected" do
    assert_no_difference "ActiveStorage::Blob.count" do
      post rails_direct_uploads_path, params: @blob_params, as: :json
    end
    assert_response :unauthorized
  end

  test "authenticated direct upload succeeds" do
    sign_in_as users(:two)
    assert_difference "ActiveStorage::Blob.count", 1 do
      post rails_direct_uploads_path, params: @blob_params, as: :json
    end
    assert_response :success
    assert response.parsed_body.dig("direct_upload", "url").present?
  end
end
