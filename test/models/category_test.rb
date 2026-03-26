require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid with name and hex color" do
    category = @user.categories.build(name: "Trabalho", color: "#4a90d9")
    assert category.valid?
  end

  test "invalid without name" do
    category = @user.categories.build(name: "", color: "#4a90d9")
    assert_not category.valid?
    assert category.errors[:name].any?
  end

  test "invalid without color" do
    category = @user.categories.build(name: "Trabalho", color: "")
    assert_not category.valid?
    assert category.errors[:color].any?
  end

  test "invalid with non-hex color" do
    ["red", "#fff", "#ffff", "4a90d9", "#gg0000"].each do |invalid_color|
      category = @user.categories.build(name: "Teste", color: invalid_color)
      assert_not category.valid?, "Expected #{invalid_color} to be invalid"
    end
  end

  test "valid with lowercase and uppercase hex" do
    category = @user.categories.build(name: "Teste", color: "#aaBBcc")
    assert category.valid?
  end

  test "invalid with name exceeding 50 characters" do
    category = @user.categories.build(name: "a" * 51, color: "#4a90d9")
    assert_not category.valid?
    assert category.errors[:name].any?
  end

  test "nullifies notes on destroy" do
    category = categories(:work)
    note = @user.notes.create!(title: "Nota", category: category)

    category.destroy
    note.reload
    assert_nil note.category_id
  end
end
