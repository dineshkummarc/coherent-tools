require "#{$script_dir}/file-types/javascript-file.rb"

class NibFile < JavascriptFile

  def self.extension
    ".jsnib"
  end

  def content_type
    "js"
  end

end