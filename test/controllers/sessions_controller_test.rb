require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login with valid credentials returns token" do
    post session_url, params: { email_address: "one@example.com", password: "password" }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["token"].present?
    assert_equal "one@example.com", json["user"]["email_address"]
  end

  test "login with invalid credentials returns unauthorized" do
    post session_url, params: { email_address: "one@example.com", password: "wrong" }, as: :json

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert json["errors"].present?
  end

  test "logout destroys session" do
    sign_in_as(users(:one))

    assert_difference("Session.count", -1) do
      delete session_url, headers: auth_headers, as: :json
    end

    assert_response :success
  end
end
