namespace :spree_reservebar_core do
  namespace :assets do

    desc "Copies images from all app/assets directories into public/assets"
    task :sync_images => :environment do
      image_paths = Rails.application.assets.paths.select {|path| path.ends_with? "/images" }

      image_paths.reverse.each do |path|
        path << '/'

        Dir.glob(File.join(path, "**/*")) do |file|
          next if File.directory? file
          cache_name = Rails.root.join('public/assets', file.to_s.sub(path, ''))

          FileUtils.mkdir_p cache_name.dirname
          FileUtils.cp file, cache_name.to_s
        end
      end
    end


  end
end
