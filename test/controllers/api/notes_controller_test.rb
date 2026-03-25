require "test_helper"

class Api::NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "index returns user notes" do
    get api_notes_url, headers: auth_headers
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal users(:one).notes.count, json.length
  end

  test "index returns notes in descending order" do
    get api_notes_url, headers: auth_headers
    json = JSON.parse(response.body)

    dates = json.map { |n| n["created_at"] }
    assert_equal dates, dates.sort.reverse
  end

  test "index requires authentication" do
    get api_notes_url
    assert_response :unauthorized
  end

  test "create with valid params" do
    assert_difference("Note.count", 1) do
      post api_notes_url, params: { note: { title: "Nova nota", content: "Conteúdo" } }, headers: auth_headers, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Nova nota", json["title"]
    assert_equal users(:one).id, json["user_id"]
  end

  test "create without content succeeds" do
    assert_difference("Note.count", 1) do
      post api_notes_url, params: { note: { title: "Só título" } }, headers: auth_headers, as: :json
    end

    assert_response :created
  end

  test "create without title returns errors" do
    assert_no_difference("Note.count") do
      post api_notes_url, params: { note: { title: "", content: "Conteúdo" } }, headers: auth_headers, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"], "Title can't be blank"
  end

  test "show returns a note" do
    note = notes(:with_content)
    get api_note_url(note), headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal note.title, json["title"]
  end

  test "show returns 404 for nonexistent note" do
    get api_note_url(id: 999999), headers: auth_headers, as: :json
    assert_response :not_found
  end

  test "update with valid params" do
    note = notes(:with_content)
    patch api_note_url(note), params: { note: { title: "Atualizado" } }, headers: auth_headers, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Atualizado", json["title"]
  end

  test "update with invalid params returns errors" do
    note = notes(:with_content)
    patch api_note_url(note), params: { note: { title: "" } }, headers: auth_headers, as: :json

    assert_response :unprocessable_entity
  end

  test "destroy deletes the note" do
    note = notes(:with_content)
    assert_difference("Note.count", -1) do
      delete api_note_url(note), headers: auth_headers, as: :json
    end

    assert_response :no_content
  end

  test "cannot access other user notes" do
    other_user = users(:two)
    other_note = other_user.notes.create!(title: "Nota secreta")

    get api_note_url(other_note), headers: auth_headers, as: :json
    assert_response :not_found
  end
end
