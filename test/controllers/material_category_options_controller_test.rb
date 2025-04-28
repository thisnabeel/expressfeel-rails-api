require "test_helper"

class MaterialCategoryOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @material_category_option = material_category_options(:one)
  end

  test "should get index" do
    get material_category_options_url, as: :json
    assert_response :success
  end

  test "should create material_category_option" do
    assert_difference("MaterialCategoryOption.count") do
      post material_category_options_url, params: { material_category_option: { language_id: @material_category_option.language_id, position: @material_category_option.position, title: @material_category_option.title } }, as: :json
    end

    assert_response :created
  end

  test "should show material_category_option" do
    get material_category_option_url(@material_category_option), as: :json
    assert_response :success
  end

  test "should update material_category_option" do
    patch material_category_option_url(@material_category_option), params: { material_category_option: { language_id: @material_category_option.language_id, position: @material_category_option.position, title: @material_category_option.title } }, as: :json
    assert_response :success
  end

  test "should destroy material_category_option" do
    assert_difference("MaterialCategoryOption.count", -1) do
      delete material_category_option_url(@material_category_option), as: :json
    end

    assert_response :no_content
  end
end
