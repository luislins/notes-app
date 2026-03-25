require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "valid with title and content" do
    note = Note.new(title: "Título", content: "Conteúdo")
    assert note.valid?
  end

  test "valid with title only" do
    note = Note.new(title: "Título")
    assert note.valid?
  end

  test "invalid without title" do
    note = Note.new(title: nil)
    assert_not note.valid?
    assert_includes note.errors[:title], "can't be blank"
  end

  test "invalid with empty title" do
    note = Note.new(title: "")
    assert_not note.valid?
  end
end
