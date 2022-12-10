namespace :codes do
  desc 'Create ISO 3166-1 code classes from Wikipedia ISO 3166-1 tables.'
  task :update do
    dirname = File.dirname(__FILE__)
    gen     = File.join(dirname, %w{iso_3166_1.rb})
    lib     = File.expand_path(File.join(dirname, %w{.. lib iso_country_codes iso_3166_1.rb}))
    require gen
    modules = IsoCountryCodes::Task::UpdateCodes.get
    File.open(lib, File::CREAT | File::TRUNC | File::WRONLY) do |f|
      f.write modules
    end
  end
end # :currency
