require "test_helper"

class Api::NotesControllerTest < ActionDispatch::IntegrationTest
  test "index returns all notes" do
    get api_notes_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal Note.count, json.length
  end

  test "index returns notes in descending order" do
    get api_notes_url
    json = JSON.parse(response.body)

    dates = json.map { |n| n["created_at"] }
    assert_equal dates, dates.sort.reverse
  end

  test "create with valid params" do
    assert_difference("Note.count", 1) do
      post api_notes_url, params: { note: { title: "Nova nota", content: "Conteúdo" } }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Nova nota", json["title"]
    assert_equal "Conteúdo", json["content"]
  end

  test "create without content succeeds" do
    assert_difference("Note.count", 1) do
      post api_notes_url, params: { note: { title: "Só título" } }, as: :json
    end

    assert_response :created
  end

  test "create without title returns errors" do
    assert_no_difference("Note.count") do
      post api_notes_url, params: { note: { title: "", content: "Conteúdo" } }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"], "Title can't be blank"
  end
end
