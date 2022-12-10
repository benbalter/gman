# encoding: utf-8

require 'erb'

module RubyProf
  # Generates graph[link:files/examples/graph_html.html] profile reports as html.
  # To use the graph html printer:
  #
  #   result = RubyProf.profile do
  #     [code to profile]
  #   end
  #
  #   printer = RubyProf::GraphHtmlPrinter.new(result)
  #   printer.print(STDOUT, :min_percent=>0)
  #
  # The Graph printer takes the following options in its print methods:
  #   :filename    - specify a file to use that contains the ERB
  #                  template to use, instead of the built-in self.template
  #
  #   :template    - specify an ERB template to use, instead of the
  #                  built-in self.template
  #
  #    :editor_uri - Specifies editor uri scheme used for opening files
  #                  e.g. :atm or :mvim. For OS X default is :txmt.
  #                  Use RUBY_PROF_EDITOR_URI environment variable to overide.

  class GraphHtmlPrinter < AbstractPrinter
    include ERB::Util

    def setup_options(options)
      super(options)

      filename = options[:filename]
      template = filename ? File.read(filename).untaint : (options[:template] || self.template)
      @erb = ERB.new(template)
      @erb.filename = filename
    end

    def print(output = STDOUT, options = {})
      @output = output
      setup_options(options)
      @editor = editor_uri
      @output << @erb.result(binding).split("\n").map(&:rstrip).join("\n") << "\n"
    end

    # Creates a link to a method.  Note that we do not create
    # links to methods which are under the min_perecent
    # specified by the user, since they will not be
    # printed out.
    def create_link(thread, overall_time, method)
      total_percent = (method.total_time/overall_time) * 100
      if total_percent < min_percent
        # Just return name
        h method.full_name
      else
        href = '#' + method_href(thread, method)
        "<a href=\"#{href}\">#{h method.full_name}</a>"
      end
    end

    def method_href(thread, method)
      h(method.full_name.gsub(/[><#\.\?=:]/,"_") + "_" + thread.fiber_id.to_s)
    end

    def file_link(path, linenum)
      srcfile = File.expand_path(path)
      if srcfile =~ /\/ruby_runtime$/
        ""
      else
        if @editor
          "<a href=\"#{@editor}://" \
          "open?url=file://#{h srcfile}&line=#{linenum}\"" \
          "title=\"#{h srcfile}:#{linenum}\">#{linenum}</a>"
        else
          "<a href=\"file://#{h srcfile}##{linenum}\" title=\"#{h srcfile}:#{linenum}\">#{linenum}</a>"
        end
      end
    end

    def template
'
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <style media="all" type="text/css">
    table {
      border-collapse: collapse;
      border: 1px solid #CCC;
      font-family: Verdana, Arial, Helvetica, sans-serif;
      font-size: 9pt;
      line-height: normal;
      width: 100%;
    }

    th {
      text-align: center;
      border-top: 1px solid #FB7A31;
      border-bottom: 1px solid #FB7A31;
      background: #FFC;
      padding: 0.3em;
      border-left: 1px solid silver;
    }

    tr.break td {
      border: 0;
      border-top: 1px solid #FB7A31;
      padding: 0;
      margin: 0;
    }

    tr.method td {
      font-weight: bold;
    }

    td {
      padding: 0.3em;
    }

    td:first-child {
      width: 190px;
      }

    td {
      border-left: 1px solid #CCC;
      text-align: center;
    }

    .method_name {
      text-align: left;
    }

    tfoot td {
      text-align: left;
    }
  </style>
  </head>
  <body>
    <h1>Profile Report: <%= RubyProf.measure_mode_string %></h1>
    <!-- Threads Table -->
    <table>
      <tr>
        <th>Thread ID</th>
        <th>Fiber ID</th>
        <th>Total Time</th>
      </tr>
      <% for thread in @result.threads %>
      <tr>
        <td><%= thread.id %></td>
        <td><a href="#<%= thread.fiber_id %>"><%= thread.fiber_id %></a></td>
        <td><%= thread.total_time %></td>
      </tr>
      <% end %>
    </table>
    <!-- Methods Tables -->
    <%
       for thread in @result.threads
         methods = thread.methods
         total_time = thread.total_time
    %>
      <h2><a name="<%= thread.fiber_id %>">Thread <%= thread.id %>, Fiber: <%= thread.fiber_id %></a></h2>
      <table>
        <thead>
          <tr>
            <th>%Total</th>
            <th>%Self</th>
            <th>Total</th>
            <th>Self</th>
            <th>Wait</th>
            <th>Child</th>
            <th>Calls</th>
            <th class="method_name">Name</th>
            <th>Line</th>
          </tr>
        </thead>
        <tbody>
          <%
             min_time = @options[:min_time] || (@options[:nonzero] ? 0.005 : nil)
             methods.sort_by(&sort_method).reverse_each do |method|
               total_percentage = (method.total_time/total_time) * 100
               next if total_percentage < min_percent
               next if min_time && method.total_time < min_time
               self_percentage = (method.self_time/total_time) * 100
          %>
               <!-- Parents -->
               <%
                  for caller in method.aggregate_parents.sort_by(&:total_time)
                    next unless caller.parent
                    next if min_time && caller.total_time < min_time
               %>
                 <tr>
                   <td>&nbsp;</td>
                   <td>&nbsp;</td>
                   <td><%= sprintf("%.2f", caller.total_time) %></td>
                   <td><%= sprintf("%.2f", caller.self_time) %></td>
                   <td><%= sprintf("%.2f", caller.wait_time) %></td>
                   <td><%= sprintf("%.2f", caller.children_time) %></td>
                   <td><%= "#{caller.called}/#{method.called}" %></td>
                   <td class="method_name"><%= create_link(thread, total_time, caller.parent.target) %></td>
                   <td><%= file_link(caller.parent.target.source_file, caller.line) %></td>
                 </tr>
               <% end %>
               <tr class="method">
                 <td><%= sprintf("%.2f%%", total_percentage) %></td>
                 <td><%= sprintf("%.2f%%", self_percentage) %></td>
                 <td><%= sprintf("%.2f", method.total_time) %></td>
                 <td><%= sprintf("%.2f", method.self_time) %></td>
                 <td><%= sprintf("%.2f", method.wait_time) %></td>
                 <td><%= sprintf("%.2f", method.children_time) %></td>
                 <td><%= sprintf("%i", method.called) %></td>
                 <td class="method_name">
                   <a name="<%= method_href(thread, method) %>">
                     <%= method.recursive? ? "*" : " "%><%= h method.full_name %>
                   </a>
                 </td>
                 <td><%= file_link(method.source_file, method.line) %></td>
               </tr>
               <!-- Children -->
               <%
                  for callee in method.aggregate_children.sort_by(&:total_time).reverse
                    next if min_time && callee.total_time < min_time
               %>
                 <tr>
                   <td>&nbsp;</td>
                   <td>&nbsp;</td>
                   <td><%= sprintf("%.2f", callee.total_time) %></td>
                   <td><%= sprintf("%.2f", callee.self_time) %></td>
                   <td><%= sprintf("%.2f", callee.wait_time) %></td>
                   <td><%= sprintf("%.2f", callee.children_time) %></td>
                   <td><%= "#{callee.called}/#{callee.target.called}" %></td>
                   <td class="method_name"><%= create_link(thread, total_time, callee.target) %></td>
                   <td><%= file_link(method.source_file, callee.line) %></td>
                 </tr>
               <% end %>
               <!-- Create divider row -->
               <tr class="break"><td colspan="9"></td></tr>
          <% end %>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="9">* indicates recursively called methods</td>
          </tr>
        </tfoot>
      </table>
    <% end %>
  </body>
</html>'
    end
  end
end
