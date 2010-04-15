require "test/test_helper"
require "test/rails_app/app/controllers/admin/categories_controller"

class Admin::CategoriesControllerTest < ActionController::TestCase

  def setup
    @request.session[:typus_user_id] = typus_users(:admin).id
  end

  def test_should_verify_items_are_sorted_by_position_on_list
    get :index
    assert_response :success
    assert_equal [1, 2, 3], assigns['items'].items.map(&:position)
    assert_equal [2, 3, 1], Category.all(:order => "id ASC").map(&:position)
  end

  def test_should_position_item_one_step_down
    @request.env['HTTP_REFERER'] = '/admin/categories'
    first_category = categories(:first)
    assert_equal 1, first_category.position
    second_category = categories(:second)
    assert_equal 2, second_category.position
    get :position, { :id => first_category.id, :go => 'move_lower' }
    assert_response :redirect
    assert_redirected_to @request.env['HTTP_REFERER']
    assert_equal "Record moved lower.", flash[:notice]
    assert_equal 2, first_category.reload.position
    assert_equal 1, second_category.reload.position
  end

  def test_should_position_item_one_step_up
    first_category = categories(:first)
    assert_equal 1, first_category.position
    second_category = categories(:second)
    assert_equal 2, second_category.position
    get :position, { :id => second_category.id, :go => 'move_higher' }
    assert_equal "Record moved higher.", flash[:notice]
    assert_equal 2, first_category.reload.position
    assert_equal 1, second_category.reload.position
  end

  def test_should_position_top_item_to_bottom
    first_category = categories(:first)
    assert_equal 1, first_category.position
    get :position, { :id => first_category.id, :go => 'move_to_bottom' }
    assert_equal "Record moved to bottom.", flash[:notice]
    assert_equal 3, first_category.reload.position
  end

  def test_should_position_bottom_item_to_top
    third_category = categories(:third)
    assert_equal 3, third_category.position
    get :position, { :id => third_category.id, :go => 'move_to_top' }
    assert_equal "Record moved to top.", flash[:notice]
    assert_equal 1, third_category.reload.position
  end

end
