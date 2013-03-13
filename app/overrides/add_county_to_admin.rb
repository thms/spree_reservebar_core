Deface::Override.new(:virtual_path => 'spree/admin/configurations/index',
                     :name => 'add_counties_to_admin_configurations_menu',
                     :insert_bottom => "[data-hook='admin_configurations_menu']",
                     :text => %q{
                        <tr>
                          <td><%= link_to 'County', admin_counties_path %></td>
                          <td>Manage Counties</td>
                        </tr> },
                      :disabled => false)
