require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params
  attr_writer :req, :res

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    @res.set_header('location', url)
    @res.status = 302
    if already_built_response?
      raise "Error"
    else
      @already_built_response = true
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res['Content-Type'] = content_type
    @res.write(content)
    if already_built_response?
      raise "Error"
    else
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = File.dirname(__FILE__)
    template_name = File.join(path, "..", "views", self.class.name.underscore, "#{template_name}.html.erb")
    pre_content = File.read(template_name)
    final_content = ERB.new(pre_content).result(binding)
    render_content(final_content, "text/html")
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
