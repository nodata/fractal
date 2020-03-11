
Pod::Spec.new do |s|
  s.name         = "Fractal"
  s.version      = "0.0.1"
  s.summary      = "Atomic Design Theory for iOS made easy"
  s.description  = "Rapid Prototyping • Quick Rebranding • Reusable UI • Minimum Code"
  s.homepage     = "https://github.com/nodata/fractal"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = ['Anthony Smith', 'Jon Bott', 'Alberto Cantallops', 'Mercari, Inc.']
  s.source       = { :git => 'https://github.com/nodata/fractal.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'

  s.source_files = 'DesignSystem/Sources/**/*.{swift,h}'
  s.resources = 'DesignSystem/Resources/Images.xcassets/**/*.{png,jpeg,jpg,pdf,json,storyboard,xib,xcassets}'

  s.frameworks = 'UIKit'
end
