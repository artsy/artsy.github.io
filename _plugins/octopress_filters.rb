# Custom filters taken from Octopress

class SVGTag < Liquid::Tag
  def render(context)
    File.read context["project"]["svg"]
  end
end

Liquid::Template.register_tag('svg_for_project', SVGTag)
