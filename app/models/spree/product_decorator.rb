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

  def self.rlike_any(fields, values)
    where_str = fields.map { |field| Array.new(values.size, "#{self.quoted_table_name}.#{field} RLIKE ?").join(' OR ') }.join(' OR ')
    self.where([where_str, values.map { |value| "[[:<:]]#{value}" } * fields.size].flatten)
  end

end
