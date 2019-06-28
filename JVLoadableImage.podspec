Pod::Spec.new do |s|
  s.name             = 'JVLoadableImage'
  s.version          = '0.3.4'
  s.summary          = 'A short description of JVLoadableImage.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Jasperav/JVLoadableImage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jasperav' => 'Jasperav@hotmail.com' }
  s.source           = { :git => 'https://github.com/Jasperav/JVLoadableImage.git', :tag => s.version.to_s }


  s.ios.deployment_target = '13.0'

  s.source_files = 'JVLoadableImage/Classes/**/*'

   s.dependency 'JVConstraintEdges'
s.dependency 'JVGenericNotificationCenter'
s.dependency 'JVUIButton'
end
