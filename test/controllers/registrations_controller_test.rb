require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "register with valid params creates user and returns token" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: { email_address: "new@example.com", password: "password", password_confirmation: "password" }
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["token"].present?
    assert_equal "new@example.com", json["user"]["email_address"]
  end

  test "register with existing email returns errors" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: { email_address: "one@example.com", password: "password", password_confirmation: "password" }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].present?
  end

  test "register with mismatched passwords returns errors" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: { email_address: "new@example.com", password: "password", password_confirmation: "wrong" }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end
end
