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
    assert_includes note.errors[:title], "can't be blank"
  end

  test "invalid with empty title" do
    note = @user.notes.build(title: "")
    assert_not note.valid?
  end
end
