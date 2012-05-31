ENV['RAILS_ENV'] = 'test'
require 'test/unit'
# require 'flexmock'
# require 'flexmock/test_unit'

active_support_lib_directory = "/Users/mvanholstyn/mhs/fusionary/wingnut/trunk/vendor/rails/activesupport/lib"
$:<< active_support_lib_directory
require 'active_support'

action_pack_lib_directory = "/Users/mvanholstyn/mhs/fusionary/wingnut/trunk/vendor/rails/actionpack/lib"
$:<< action_pack_lib_directory
require 'action_controller'
require 'action_controller/test_process'

class ApplicationPresenter < ActionView::Base
end

require File.join(File.dirname(__FILE__), '..', 'init')