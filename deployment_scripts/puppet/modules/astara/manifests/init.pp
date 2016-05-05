#
# Copyright (c) 2016, Akanda Inc, http://akanda.io
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

notice('MODULAR: astara/init.pp')

# Parameters for configuring Astara Fuel plugin
class astara {
    $astara_settings = hiera('fuel-plugin-astara')
    $mgt_service_port = $astara_settings['astara_mgmt_service_port']
}
#
#  $astara_settings = hiera('astara', {})
#  $management_vip = hiera('management_vip')
#
#  # Settings for Neutron 
#  $neutron_settings = hiera_hash('quantum_settings', {})
#
#  # Setting for Authenication
#  $ssl_hash               = hiera_hash('use_ssl', {})
#  $internal_auth_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
#  $internal_auth_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [hiera('service_endpoint', ''), $management_vip])
#  $admin_auth_protocol    = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
#  $admin_auth_address     = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', [hiera('service_endpoint', ''), $management_vip])
#
#  $auth_uri          = "${internal_auth_protocol}://${internal_auth_address}:5000/v2.0/"
#  $auth_url          = "${admin_auth_protocol}://${admin_auth_address}:35357/"
#  $identity_uri      = "${admin_auth_protocol}://${admin_auth_address}:35357/"
#  $auth_region       = hiera('region', 'RegionOne')
#  $project_domain_id = hiera('project_domain', 'default')
#  $project_name      = hiera('$hiera workloads_collector['tenant']', 'services')
#  $user_domain_id    = hiera('user_domain', 'default')
#  $neutron_user      = hiera('neutron_user', 'neutron')
#  $neutron_password  = hiera('neutron_user_password')
#
#  # Settings for Database
#  $database_vip = hiera('database_vip', undef)
#  $db_type      = 'mysql'
#  $db_host      = pick($astara_settings['db_host'], $database_vip)
#  $db_user      = pick($astara_settings['username'], 'astara')
#  $db_password  = $astara_settings['db_password']
#  $db_name      = pick($astara_settings['db_name'], 'astara')
#  $db_connection = os_database_connection({
#    'dialect'  => $db_type,
#    'host'     => $db_host,
#    'database' => $db_name,
#    'username' => $db_user,
#    'password' => $db_password,
#    'charset'  => 'utf8'
#  })
#
#  # Settings for RabbitMQ 
#  $rabbit             = hiera_hash('rabbit_hash')
#  $rabbit_user        = $rabbit['user']
#  $rabbit_password    = $rabbit['password']
#  $rabbit_hosts       = split(hiera('amqp_hosts',''), ',')
#
#  # Settings for Astara
##  $mangement_network_id = 
##  $management_subnet_id =
#  $management_prefix = $astara_settings['astara-mgmt-ipv6-prefix']
##  $external_network_id = 
##  $external_subnet_id = 
#  $external_prefix = $neutron_settings['predefined_networks']['admin_floating_net']['L3']['subnet']
#  $enable_drivers = pick($astara_settings['enable_drivers'], 'router')
#  $interface_driver = pick($astara_settings['interface_driver'], 'astara.common.linux.interface.OVSInterfaceDriver')
#  $instance_provider = pick($astara_settings['instance_provider'], 'on-demand')
#  $bind_api_port = $astara_settings['astara-api-port']
#  $bind_mgmt_port = $astara_settings['astara-mgmt-service-port']
#
#  #$appliance_router_image = {
#  #  "os_name" => "astara_router",
#  #  "loc_path" => $settings['astara_appliance_image_loc']
#  #  "container_format" => "bare",
#  #  "disk_format" => "qcow2",
#  #  "glance_properties" => "",
#  #  "img_name" => "astara_router",
#  #  "public" => "true"
#  #}
#  #$appliance_lb_image = {
#  #  "os_name" => "astara_nginx",
#  #  "loc_path" => $settings['astara_appliance_image_loc']
#  #  "container_format" => "bare",
#  #  "disk_format" => "qcow2",
#  #  "glance_properties" => "",
#  #  "img_name" => "astara_nginx",
#  #  "public" => "true"
#  #}
#}
