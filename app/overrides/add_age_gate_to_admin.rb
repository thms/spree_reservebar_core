Deface::Override.new(:virtual_path => 'spree/admin/configurations/index',
                     :name => 'add_age_gates_to_admin_configurations_menu',
                     :insert_bottom => "[data-hook='admin_configurations_menu']",
                     :text => %q{
                        <tr>
                          <td><%= link_to 'Age Gate', admin_age_gates_path %></td>
                          <td>Manage Age Gates</td>
                        </tr> },
                      :disabled => false)
