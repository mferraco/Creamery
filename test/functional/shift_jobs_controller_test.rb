require 'test_helper'

class ShiftJobsControllerTest < ActionController::TestCase
  setup do
    @shift_job = shift_jobs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shift_jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shift_job" do
    assert_difference('ShiftJob.count') do
      post :create, shift_job: @shift_job.attributes
    end

    assert_redirected_to shift_job_path(assigns(:shift_job))
  end

  test "should show shift_job" do
    get :show, id: @shift_job
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shift_job
    assert_response :success
  end

  test "should update shift_job" do
    put :update, id: @shift_job, shift_job: @shift_job.attributes
    assert_redirected_to shift_job_path(assigns(:shift_job))
  end

  test "should destroy shift_job" do
    assert_difference('ShiftJob.count', -1) do
      delete :destroy, id: @shift_job
    end

    assert_redirected_to shift_jobs_path
  end
end
