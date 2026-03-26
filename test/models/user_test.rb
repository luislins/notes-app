require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "invalid without email" do
    user = User.new(email_address: "", password: "password123")
    assert_not user.valid?
    assert user.errors[:email_address].any?
  end

  test "invalid with duplicate email" do
    User.create!(email_address: "dup@example.com", password: "password123")
    user = User.new(email_address: "dup@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:email_address].any?
  end

  test "invalid with malformed email" do
    ["invalid", "no@", "@nodomain", "spaces in@email.com"].each do |bad_email|
      user = User.new(email_address: bad_email, password: "password123")
      assert_not user.valid?, "Expected #{bad_email} to be invalid"
    end
  end

  test "invalid with password shorter than 8 characters" do
    user = User.new(email_address: "short@example.com", password: "1234567")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "valid with password of 8 characters" do
    user = User.new(email_address: "ok@example.com", password: "12345678")
    assert user.valid?
  end

  test "destroys notes on destroy" do
    user = users(:one)
    user.notes.create!(title: "Nota para destruir")
    assert_difference("Note.count", -user.notes.count) do
      user.destroy
    end
  end

  test "destroys categories on destroy" do
    user = users(:one)
    assert_difference("Category.count", -user.categories.count) do
      user.destroy
    end
  end
end
