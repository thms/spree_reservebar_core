# Stores the url paths that require showing an age gate
# if the global preference to use age gate on all pages is set, this is not used.
class Spree::AgeGate < ActiveRecord::Base
  
  # Returns true if an age gate should be shown on the url path
  def self.apply_for_path?(path)
    # Need to normalize path, since we still might have double slashes, can remove this when the double slashes are gone
    if path[0..1] == '//'
      path = path[1..-1]
    end
    exists?(:path => path)
  end
end