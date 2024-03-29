require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params
    @session = Session.new(req)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise Error if already_built_response?
    @res.body = content
    @res.content_type = type
    @already_built_response = @res
    @session.store_session(@res)
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ? true : false
  end

  # set the response status code and header
  def redirect_to(url)
    raise Error if already_built_response?
    @res.status = 302
    @res.header["location"] = url
    @already_built_response = @res
    @session.store_session(@res)
    # self.set_redirect(self.status, url)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    
    contents = File.read("views/#{self.class.name.to_s.underscore}/#{template_name}.html.erb")

    template = ERB.new(contents).result(binding)

    render_content(template, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session
  end



  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
