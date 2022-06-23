

Pod::Spec.new do |s|
  s.name         = "EasyAddressBook"
  s.version      = "0.1.1"
  s.summary      = "EasyAddressBook"
  s.description  = <<-DESC
			my first cocoapods repository daklsjgklafasjkfajslkdjalskjglkasjdlkajslkdjlkfajsldkla
                   DESC

  s.homepage     = "https://github.com/Alienchang/EasyAddressBook"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Alienchang" => "1217493217@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/Alienchang/EasyAddressBook.git", :tag => "#{s.version}" }
  s.source_files  = "*.{h,m}"
  s.exclude_files = "Classes/Exclude"

end
