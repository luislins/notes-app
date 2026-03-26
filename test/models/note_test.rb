require "test_helper"

class NoteTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid with title and content" do
    note = @user.notes.build(title: "Título", content: "Conteúdo")
    assert note.valid?
  end

  test "valid with title only" do
    note = @user.notes.build(title: "Título")
    assert note.valid?
  end

  test "invalid without title" do
    note = @user.notes.build(title: nil)
    assert_not note.valid?
    assert_includes note.errors[:title], "não pode ficar em branco"
  end

  test "invalid with empty title" do
    note = @user.notes.build(title: "")
    assert_not note.valid?
  end

  test "invalid with title exceeding 255 characters" do
    note = @user.notes.build(title: "a" * 256)
    assert_not note.valid?
    assert note.errors[:title].any?
  end

  test "invalid with content exceeding 10000 characters" do
    note = @user.notes.build(title: "Título", content: "a" * 10_001)
    assert_not note.valid?
    assert note.errors[:content].any?
  end

  test "valid with category from same user" do
    category = categories(:work)
    note = @user.notes.build(title: "Título", category: category)
    assert note.valid?
  end

  test "invalid with category from another user" do
    other_category = categories(:other_user_category)
    note = @user.notes.build(title: "Título", category: other_category)
    assert_not note.valid?
    assert note.errors[:category].any?
  end

  test "valid without category" do
    note = @user.notes.build(title: "Título", category: nil)
    assert note.valid?
  end
end
