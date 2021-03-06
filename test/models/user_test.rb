require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "A User", email: "user@test.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "n" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "e" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_bz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    evan = users(:evan)
    mike = users(:mike)
    assert_not evan.following?(mike)
    evan.follow(mike)
    assert evan.following?(mike)
    assert mike.followers.include?(evan)
    evan.unfollow(mike)
    assert_not evan.following?(mike)
  end

  test "feed should have the right posts" do
    evan = users(:evan)
    kristen = users(:kristen)
    neal = users(:neal)
    # Posts from followed user
    kristen.microposts.each do |post_following|
      assert evan.feed.include?(post_following)
    end
    # Posts from self
    evan.microposts.each do |post_self|
      assert evan.feed.include?(post_self)
    end
    # Posts from unfollowed user
    neal.microposts.each do |post_unfollowed|
      assert_not kristen.feed.include?(post_unfollowed)
    end
  end

end
