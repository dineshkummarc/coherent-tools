require "#{$script_dir}/tasks/javascript-task.rb"

class BundleTask < JavascriptTask

  content_type "js"
  output_type "jsbundle"
    
  # NibTask handles files that end in .jsnib
  def handles_file?(file)
    ['js', 'css'].include?(file.content_type)
  end

  def process_file(file)
    destination= File.expand_path(remove_prefix||"")
    jsfile= JavascriptFile.new(@name_concat)
    
    if (!@concat.empty?)
      @concat << @concatenation_join_string||""
    end
    
    case file.content_type
    when "js"
      @concat << file.filtered_content(options)
      @debug << file.debug_content(options)
    when "css"
      included_content= file.filtered_content(options)
      included_content= file.minify_content(included_content)
      
      included_content= jsfile.escape_embeded_content(included_content)
      
      @concat << "NIB.asset('#{file.relative_to_folder(destination)}', '#{included_content}');\n"
    else
      file.warning "Unknown file type: #{file.content_type}"
    end
  end
  
end
