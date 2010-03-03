require "#{$script_dir}/file-types/javascript-file.rb"

class NibFile < JavascriptFile

  def self.extension
    ".jsnib"
  end

  def content_type
    "js"
  end

end

# class JslDependencyFilter < Filter
#   
#   def handles_file(file)
#     return [".js", ".jsnib"].include?(file.extension)
#   end
#   
# end
