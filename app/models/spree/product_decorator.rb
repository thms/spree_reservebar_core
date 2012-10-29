Spree::Product.class_eval do
  
  # scope for finding products in a set of taxon trees
  scope :taxons_id_in_tree_any, lambda {|*taxons| 
    taxons = [taxons].flatten
    { :conditions => [ "spree_products.id in (select product_id from spree_products_taxons where taxon_id in (?))", 
      taxons.map {|i| i.is_a?(Spree::Taxon) ? i : Spree::Taxon.find(i)}.
 	                  reject {|t| t.nil?}.
                    map    {|t| [t] + t.descendants}.flatten ]}
    }
    
  # scope for finding all products in a taxon tree  
  scope :taxons_id_in_tree, lambda {|taxon| 
    Product.taxons_id_in_tree_any(taxon).scope :find 
  }
  
  # Used by autosuggest to remove deleted products
  def self.deleted
    where('deleted_at is not ?', nil)
  end
  
   # Used by autosuggest to remove deleted products
  def self.non_available(available_on = nil)
    where('available_on >= ?', available_on || Time.now)
  end

  def self.rlike_any(fields, values)
    where_str = fields.map { |field| Array.new(values.size, "#{self.quoted_table_name}.#{field} RLIKE ?").join(' OR ') }.join(' OR ')
    self.where([where_str, values.map { |value| "[[:<:]]#{value}" } * fields.size].flatten)
  end
  
  # searches in name and taxon name, finds all products in a taxon if the taxon name matches the search
  def self.rlike_any_or_in_taxons(fields, values)
    where_str = fields.map { |field| Array.new(values.size, "#{self.quoted_table_name}.#{field} RLIKE ?").join(' OR ') }.join(' OR ')
    ## taxons = Spree::Product.get_taxons(values)
    taxons = Spree::Product.get_related_taxons(values)
    if taxons.blank?
    	self.where([where_str, values.map { |value| "[[:<:]]#{value}" } * fields.size].flatten)
    else
		  where_str << " OR spree_taxons.id in (?)"
		  #self.where([where_str, values.map { |value| "[[:<:]]#{value}" } * fields.size, taxons.map(&:id)].flatten)
		  self.where([where_str, values.map { |value| "[[:<:]]#{value}" } * fields.size].flatten << taxons.map{|s|s.self_and_descendants}.flatten.map(&:id).uniq)
    end
  end
  
  # Methods to find all states that this product can ship to, based on existing retailers and their settings
  # Used on product page to sow where this product can be shipped to
  # This could probably do with some pretty heavy caching
  def ships_to_states
    method = "ships_#{self.shipping_category.name.downcase.gsub(' ','_')}_to".to_sym
    states = Spree::Retailer.active.map(&method).join(',').split(',').uniq.sort.to_sentence
  end
  
  # Returns true if this product is availble for shipping to all states.
  def ships_to_all_states?
    method = "ships_#{self.shipping_category.name.downcase.gsub(' ','_')}_to".to_sym
    Spree::Retailer.active.map(&method).join(',').split(',').uniq.count == Spree::State.count
  end
  
  private
  
	def self.get_related_taxons(*ids_or_records_or_names)
	  taxons = Spree::Taxon.table_name
	  ids_or_records_or_names.flatten.map { |t|
	    case t
	    when Integer then Taxon.find_by_id(t)
	    when ActiveRecord::Base then t
	    when String
	      Spree::Taxon.find_by_name(t) ||
	      Spree::Taxon.find(:first, :conditions => [
	        "#{taxons}.permalink LIKE ? OR #{taxons}.permalink = ?", "%#{t}%", "#{t}/"
	      ])
	    end
	  }.compact.flatten.uniq
	end
end
