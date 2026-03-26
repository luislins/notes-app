require "test_helper"

class Api::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "index returns user categories" do
    get api_categories_url, headers: auth_headers
    assert_response :success

    json = JSON.parse(response.body)
    user_categories = users(:one).categories.count
    assert_equal user_categories, json.length
  end

  test "index does not return other user categories" do
    get api_categories_url, headers: auth_headers
    json = JSON.parse(response.body)

    names = json.map { |c| c["name"] }
    assert_not_includes names, categories(:other_user_category).name
  end

  test "index requires authentication" do
    get api_categories_url
    assert_response :unauthorized
  end

  test "create with valid params" do
    assert_difference("Category.count", 1) do
      post api_categories_url, params: { category: { name: "Estudos", color: "#ff5733" } }, headers: auth_headers, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Estudos", json["name"]
    assert_equal "#ff5733", json["color"]
  end

  test "create without name returns errors" do
    assert_no_difference("Category.count") do
      post api_categories_url, params: { category: { name: "", color: "#ff5733" } }, headers: auth_headers, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("Nome") }
  end

  test "create with invalid color returns errors" do
    assert_no_difference("Category.count") do
      post api_categories_url, params: { category: { name: "Teste", color: "red" } }, headers: auth_headers, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "update with valid params" do
    category = categories(:work)
    patch api_category_url(category), params: { category: { name: "Novo nome" } }, headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Novo nome", json["name"]
  end

  test "update with invalid params returns errors" do
    category = categories(:work)
    patch api_category_url(category), params: { category: { name: "" } }, headers: auth_headers, as: :json

    assert_response :unprocessable_entity
  end

  test "destroy deletes the category" do
    category = categories(:work)
    assert_difference("Category.count", -1) do
      delete api_category_url(category), headers: auth_headers, as: :json
    end

    assert_response :no_content
  end

  test "destroy nullifies associated notes" do
    category = categories(:work)
    note = users(:one).notes.create!(title: "Nota com categoria", category: category)

    delete api_category_url(category), headers: auth_headers, as: :json
    assert_response :no_content

    note.reload
    assert_nil note.category_id
  end

  test "cannot access other user categories" do
    other_category = categories(:other_user_category)
    patch api_category_url(other_category), params: { category: { name: "Hack" } }, headers: auth_headers, as: :json

    assert_response :not_found
  end
end
