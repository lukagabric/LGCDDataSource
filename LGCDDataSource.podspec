Pod::Spec.new do |s|
  s.name         = "LGCDDataSource"
  s.version      = "1.0"
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'https://github.com/lukagabric/LGCDDataSource'}
  s.source_files = "LGDataSource/Classes/Core/Parsers/*.{h,m}", "LGDataSource/Classes/Core/DataUpdate/*.{h,m}"
  s.dependency 'MagicalRecord'
  s.dependency 'PromiseKit'
  s.dependency 'MBProgressHUD'
  s.requires_arc = true
end
