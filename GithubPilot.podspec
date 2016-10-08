Pod::Spec.new do |s|
  s.platform 	 = :ios
  s.ios.deployment_target = '9.0'
  s.name         = "GithubPilot"
  s.version      = "1.1.10"
  s.summary      = "Github API V3 Swifty Wrapper"
  s.description  = <<-DESC
                    A swift implementaion of Github API V3, make query to Github easier.
                   DESC

  s.homepage     = "https://github.com/jindulys/GithubPilot"
  s.license      = { :type => "MIT", :file => "LICENCE" }


  s.author             = { "yansong li" => "liyansong.edw@gmail.com" }

  s.source       = { :git => "https://github.com/jindulys/GithubPilot.git", :tag => s.version }

  s.source_files = "Sources/**/*.*"
  s.requires_arc = true
  s.dependency 'Alamofire', '~> 4.0.0'
  s.ios.framework    = "UIKit"
end
