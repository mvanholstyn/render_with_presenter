#TODO: app/presenters on load path...
require File.dirname(__FILE__) + '/lib/render_with_presenter'

class ActionView::Base
  include ActionView::Presenters
end

class ActionController::Base
  include ActionController::Presenters
end