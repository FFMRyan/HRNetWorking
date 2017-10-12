Pod::Spec.new do |s|
    s.name         = "HRNetWorking"
    s.version      = "1.0.0"
    s.ios.deployment_target = '8.0'
    s.summary      = "HRNetWorking是一个iOS组件化开发的组件之一，主要用来网络请求管理"
    s.homepage     = "https://github.com/iOSGeekerOfChina/HRNetWorking.git"
    s.license              = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "iOSGeekOfChina" => "danny@cecelive.com" }
    s.social_media_url   = "http://www.geek00.com"
    s.source       = { :git => "https://github.com/iOSGeekerOfChina/HRNetWorking.git", :tag => s.version }
    s.source_files  = "HRNetWorking/*.{h,m}" 
    s.requires_arc = true
end



