require "test_helper"

class MaterialTagOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @material_tag_option = material_tag_options(:one)
  end

  test "should get index" do
    get material_tag_options_url, as: :json
    assert_response :success
  end

  test "should create material_tag_option" do
    assert_difference("MaterialTagOption.count") do
      post material_tag_options_url, params: { material_tag_option: { language_id: @material_tag_option.language_id, position: @material_tag_option.position, title: @material_tag_option.title } }, as: :json
    end

    assert_response :created
  end

  test "should show material_tag_option" do
    get material_tag_option_url(@material_tag_option), as: :json
    assert_response :success
  end

  test "should update material_tag_option" do
    patch material_tag_option_url(@material_tag_option), params: { material_tag_option: { language_id: @material_tag_option.language_id, position: @material_tag_option.position, title: @material_tag_option.title } }, as: :json
    assert_response :success
  end

  test "should destroy material_tag_option" do
    assert_difference("MaterialTagOption.count", -1) do
      delete material_tag_option_url(@material_tag_option), as: :json
    end

    assert_response :no_content
  end
end
