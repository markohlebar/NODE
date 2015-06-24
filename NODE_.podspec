Pod::Spec.new do |s|

  s.name         = "NODE_"
  s.version      = "0.1.1"
  s.summary      = "Create a tree from any objects."

  s.description  = <<-DESC
  NODE is a category on NSObject that let's you build parent - children tree
  structures from any object. 
                   DESC

  s.homepage     = "https://github.com/markohlebar/NODE"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Marko Hlebar" => "marko.hlebar@gmail.com" }
  s.social_media_url   = "https://twitter.com/markohlebar"

  s.source       = { :git => "https://github.com/markohlebar/NODE.git", :tag => "0.1.1" }
  s.source_files  = "NODE", "NODE/**/*.{h,m}"
  
  # s.public_header_files = "Classes/**/*.h"
  s.requires_arc = true
  s.platform = :ios, "7.0"

end
