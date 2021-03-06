require "xml"
require "spec"
require "markdown"

class Readme
  getter html

  def initialize(path)
    @html = to_html File.read(path)
  end

  def find(xpath)
    @html.xpath(xpath)
  end

  def get_awesomeness
    find("//ul/li/a") as XML::NodeSet
  end

  def get_refs(select = nil)
    set = find("//ul/li/a/@href") as XML::NodeSet
    refs = set.map { |node| node.text as String }
    refs.select! { |x| x =~ select} if select
    refs
  end

  def get_groups
    set = find("//ul[li]") as XML::NodeSet
    groups = set.map do |node|
      n = XML.parse(node.to_s).xpath("//li/a[1]/text()") as XML::NodeSet
      n.map { |el| el.text as String}
    end
    # FIXME: Crystal Markdown does not support inner lists
    # Should be fixed in future
    groups.shift # table of contents
    groups.pop   # editor plugins
    groups
  end

  private def to_html(markdown)
    XML.parse(%[
    <html>
      #{Markdown.to_html(markdown)}
    </html>
    ])
  end
end
