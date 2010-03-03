require "#{$script_dir}/tasks/javascript-task.rb"

class JsNibTask < JavascriptTask

  content_type "js"
  output_type "jsnib"
    
  # NibTask handles files that end in .jsnib
  def handles_file?(file_name)
    "#{file_name}"[/\.jsnib$/] || "#{file_name}"[/\.js$/]
  end
  
end
