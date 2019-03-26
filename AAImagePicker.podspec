
Pod::Spec.new do |s|
s.name             = 'AAImagePicker'
s.version          = '0.1.2'
s.summary          = 'AAImagePicker is a simple & easy-to-use image picker designed to present both camera and photo library options and get the UIImage easily.'

s.description      = <<-DESC
AAImagePicker is a basically a wrapper for `UIImagePickerController` that allows to pick image in a easy way. It is designed to present both camera and photo library options and get the UIImage easily.
DESC

s.homepage         = 'https://github.com/EngrAhsanAli/AAImagePicker'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Engr. Ahsan Ali' => 'hafiz.m.ahsan.ali@gmail.com' }
s.source           = { :git => 'https://github.com/EngrAhsanAli/AAImagePicker.git', :tag => s.version.to_s }

s.ios.deployment_target = '8.0'
s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }

s.source_files = 'AAImagePicker/Classes/**/*'

end
