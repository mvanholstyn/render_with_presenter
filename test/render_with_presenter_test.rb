require File.dirname(__FILE__) + '/test_helper'

class TestingController < ActionController::Base
  self.view_paths = [ File.dirname(__FILE__) + "/views" ]
private
  def rescue_action(exception); exception; end
end

class PeopleController < TestingController
  def show
    @person = 'Timothy'
  end
end

class PeoplePresenter < ApplicationPresenter
  attr_accessor :person
  
  def display_name
    content_tag(:h1, person)
  end
end

class RenderWithPresenterTest < Test::Unit::TestCase
  def setup
    @request      = ActionController::TestRequest.new
    @response     = ActionController::TestResponse.new
    @controller   = PeopleController.new
  end
  
  def test_rendering_from_a_controller_uses_the_presenter_for_that_controller
    get :show
    assert_equal "<h1>Tim</h1>", @response.body 
  end
end
# 
# class DeterminingDefaultPresenter < Test::Unit::TestCase
#   def setup
#     @request      = ActionController::TestRequest.new
#     @response     = ActionController::TestResponse.new
#     @request.host = "www.example.com"
#   end
#   
#   def test_rendering_an_action_for_a_controller_that_has_its_own_presenter_uses_that_presenter_as_the_template
#     @controller   = PeopleController.new
#     get :noop
#     assert_equal PeoplePresenter, @response.template.class
#   end
#   
#   def test_rendering_an_action_for_a_controller_that_does_not_have_its_own_presenter_uses_the_application_presenter_as_the_template
#     @controller   = AccountsController.new
#     get :noop
#     assert_equal ApplicationPresenter, @response.template.class
#   end
#   
#   def test_rendering_a_partial_from_a_different_controller_without_explicitly_specifying_which_presenter_to_use_chooses_the_presenter_for_the_controller_where_the_partial_lives_if_it_exists
#     @controller = AccountsController.new
#     
#     # The initial wrapping presenter
#     flexmock(ApplicationPresenter).new_instances.should_receive(:new).once.ordered
#     flexmock(ApplicationPresenter).new_instances.should_receive(:rendering_template_from_another_controller?).once.ordered
#     # Then one PeoplePresenter for each of the two person partials rendered from the people/ view directory
#     flexmock(PeoplePresenter).new_instances.should_receive(:new).once.ordered
#     get :list
#   end
#   
#   def test_object_passed_to_partial_is_set_as_an_attribute_of_the_presenter_used_to_render_the_partial_rathern_than_just_a_local
#     @controller = AccountsController.new
#     # The object was passed to the partial
#     assert_nothing_raised do
#       get :list
#     end
#     assert_match %r|<h1>Tim</h1>|, @response.body
#   end
# end
