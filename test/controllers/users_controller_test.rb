require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { apt_address: @user.apt_address, city: @user.city, email: @user.email, first_name: @user.first_name, home_phone: @user.home_phone, last_name: @user.last_name, middle_name: @user.middle_name, mobile_phone: @user.mobile_phone, preferred_branch_id: @user.preferred_branch_id, st_address: @user.st_address, state_id: @user.state_id, user_name: @user.user_name, zip: @user.zip }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { apt_address: @user.apt_address, city: @user.city, email: @user.email, first_name: @user.first_name, home_phone: @user.home_phone, last_name: @user.last_name, middle_name: @user.middle_name, mobile_phone: @user.mobile_phone, preferred_branch_id: @user.preferred_branch_id, st_address: @user.st_address, state_id: @user.state_id, user_name: @user.user_name, zip: @user.zip }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
