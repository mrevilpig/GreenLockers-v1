require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get DoorOpen" do
    get :DoorOpen
    assert_response :success
  end

  test "should get DoorClose" do
    get :DoorClose
    assert_response :success
  end

  test "should get DropOff" do
    get :DropOff
    assert_response :success
  end

  test "should get UpdateAccessInfo" do
    get :UpdateAccessInfo
    assert_response :success
  end

  test "should get UpdatePermission" do
    get :UpdatePermission
    assert_response :success
  end

end
