class PresenterGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.directory File.join( *%w( app presenters ) )
      presenter_path = 'app/presenters/presenter.rb'
      m.template presenter_path, File.join('app', 'presenters', class_path, "#{file_name}_presenter.rb")
    end
  end
  
  def file_name
    application_presenter? ? super : super.pluralize
  end
  
  def application_presenter?
    singular_name == 'application'
  end
  
  def presenter_superclass
    application_presenter? ? 'ActionView::Base' : 'ApplicationPresenter'
  end
  
  def presenter_class_name
    application_presenter? ? 'Application' : class_name.pluralize
  end
end