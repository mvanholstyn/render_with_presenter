module ActionView
  module Presenters
    def self.included(base)
      # base.cattr_accessor :presenters
      # base.presenters = {}
      base.alias_method_chain :render, :presenter
    end
    
    
    def render_with_presenter(options = {}, *args, &block)
      if options.is_a?(Hash) && name = options.delete(:presenter)
        presenter_for(name, options.delete(:assigns)).render_without_presenter(options, *args, &block)
      else
        render_without_presenter(options, *args, &block)
      end
    end
  
    # def render_with_presenter(options = {}, *args, &block)
    #   if options.is_a?(Hash) && presenter = options.delete(:presenter)
    #     presenter_for(presenter).render_without_presenter(options, *args, &block)
    #   else
    #     presenter_to_use = nil
    #     if controller_name = rendering_template_from_another_controller?(options)
    #       p "We got this controller name: #{controller_name}"
    #       presenter_to_use = presenter_for(controller_name)
    #       # Check if presenter exists!
    #     end
    #     
    #     if presenter_to_use
    #       p "Decided to use this presenter: #{presenter_to_use}"
    #       if partial_name = options[:partial]
    #         p "Going to render this partial: #{partial_name}"
    #         attribute_name = partial_name.split('/').last
    #         p "Going to set this attribute: #{attribute_name}"
    #         if object_to_inject_to_partial = options[:object]
    #           p "It's going to get this value: #{object_to_inject_to_partial.inspect}"
    #         elsif object_to_inject_to_partial = instance_variable_get("@#{attribute_name}")
    #           p "We have an instance variable called #{attribute_name} so we'll use that as the value"
    #         end
    #         
    #         if object_to_inject_to_partial
    #           presenter_to_use.send("#{attribute_name}=", object_to_inject_to_partial)
    #         end
    #       end
    #       presenter_to_use.render_without_presenter(options, *args, &block)
    #     else  
    #       render_without_presenter(options, *args, &block)
    #     end
    #   end
    # end
    
    def presenter_for(name, presenter_assigns = {})
      presenter = "#{name.to_s.classify.pluralize}Presenter".constantize.new(view_paths, assigns, controller)
      presenter_assigns.each do |attribute_name, attribute_value|
        presenter.send("#{attribute_name}=", attribute_value)
      end
      presenter
    end

    # def presenter_for(object, presenter_assigns = {})
    #   presenters[object] ||=
    #     presenter_instance_for(object) do |presenter|
    #       presenter_assigns.each do |attribute_name, attribute_value|
    #         presenter.send("#{attribute_name}=", attribute_value)
    #       end
    #     end
    # end

    # def presenters
    #   self.class.presenters
    # end

    private
      # def presenter_instance_for(object, &block)
      #   presenter_class = lambda do |name|
      #     "#{name.classify.pluralize}Presenter".constantize.new(view_paths, assigns, controller, &block)
      #   end
      # 
      #   case object
      #   when Symbol
      #     presenter_class[object.to_s]
      #   when AbstractPresenter
      #     block.call(object)
      #     object
      #   else
      #     presenter_class[object.class.name]
      #   end
      # end
      
      # def rendering_template_from_another_controller?(options)
      #   # p "Entering rendering_template_from_another_controller? with #{options.inspect}"
      #   return false unless options.is_a?(Hash)
      #   # p options
      #   requested_template  = options.values_at(:file, :template, :partial).compact.first
      #   # p requested_template
      #   return false if requested_template.nil?
      #   template_path_parts = requested_template.split('/')
      #   # p template_path_parts
      #   return false if template_path_parts.size <= 1
      #   controller_candidate = template_path_parts.first
      #   # p controller_candidate
      #   return controller_candidate.to_sym unless Object.const_get("#{controller_candidate.camelcase}Controller").nil?
      # end
  end
end

module ActionController
  module Presenters
    def self.included(base)
      # Even though we aren't chaining back, we have to use alias_method_chain rather than include because
      # the original method (initialize_template_class) is defined directly on the class and is not included
      # in from a module. As a result, a simple include will not overwrite it, as that only happens for methods that
      # were originally included in from some module.
      base.alias_method_chain :initialize_template_class, :presenter
    end
  
    private
      def initialize_template_class_with_presenter(response)
        unless template_class
          raise "You must assign a template class through ActionController.template_class= before processing a request"
        end

        response.template = determine_presenter.new(view_paths, {}, self)
        response.template.extend self.class.master_helper_module
        response.redirected_to = nil
        @performed_render = @performed_redirect = false
      end
  
      def determine_presenter
        presenter = self.class.name.gsub(/Controller$/, 'Presenter')
        presenter['Presenter'] ? presenter.constantize : ApplicationPresenter
      rescue NameError
        ApplicationPresenter
      end
  end
end