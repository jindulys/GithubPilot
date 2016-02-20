Pod::Spec.new do |s|

  s.name         = "GithubPilot"
  s.version      = "0.0.1"
  s.summary      = "Github API V3 Swifty Wrapper"
  s.description  = <<-DESC
                    A swift implementaion of Github API V3, make query to Github easier.
                   DESC

  s.homepage     = "https://github.com/jindulys/GithubPilot"
  s.license      = { :type => "MIT", :file => "LICENCE" }


  s.author             = { "yansong li" => "liyansong.edw@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/jindulys/GithubPilot.git", :tag => s.version }

  s.source_files  = "Sources/**/*.*"

  s.dependency 'Alamofire', '~> 3.0'

end
