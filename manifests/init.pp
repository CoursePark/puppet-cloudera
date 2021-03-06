# == Class: cloudera
#
# This class handles installing the Cloudera software with the intention
# of the CDH stack being managed by Cloudera Manager.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*autoupgrade*]
#   Upgrade package automatically, if there is a newer version.
#   Default: false
#
# [*service_ensure*]
#   Ensure if service is running or stopped.
#   Default: running
#
# [*service_enable*]
#   Start service at boot.
#   Default: true
#
# [*cdh_yumserver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*cdh_yumpath*]
#   The path to add to the $cdh_yumserver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*cdh_version*]
#   The version of Cloudera's Distribution, including Apache Hadoop to install.
#   Default: 4
#
# [*cm_yumserver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*cm_yumpath*]
#   The path to add to the $cm_yumserver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*cm_version*]
#   The version of Cloudera Manager to install.
#   Default: 4
#
# [*ci_yumserver*]
#   URI of the YUM server.
#   Default: http://beta.cloudera.com
#
# [*ci_yumpath*]
#   The path to add to the $ci_yumserver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*ci_version*]
#   The version of Cloudera Impala to install.
#   Default: 0
#
# [*cm_server_host*]
#   Hostname of the Cloudera Manager server.
#   Default: localhost
#
# [*cm_server_port*]
#   Port to which the Cloudera Manager server is listening.
#   Default: 7182
#
# === Actions:
#
# Installs YUM repository configuration files.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'cloudera':
#     cdh_version    => '4.1',
#     cm_version     => '4.1',
#     cm_server_host => 'smhost.example.com',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#  Copyright (c) 2011, Cloudera, Inc. All Rights Reserved.
#
#  Cloudera, Inc. licenses this file to you under the Apache License,
#  Version 2.0 (the "License"). You may not use this file except in
#  compliance with the License. You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  This software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#  CONDITIONS OF ANY KIND, either express or implied. See the License for
#  the specific language governing permissions and limitations under the
#  License.
#
class cloudera (
  $ensure         = $cloudera::params::ensure,
  $autoupgrade    = $cloudera::params::safe_autoupgrade,
  $service_ensure = $cloudera::params::service_ensure,
  $service_enable = $cloudera::params::safe_service_enable,
  $cdh_yumserver  = $cloudera::params::cdh_yumserver,
  $cdh_yumpath    = $cloudera::params::cdh_yumpath,
  $cdh_version    = $cloudera::params::cdh_version,
  $cm_yumserver   = $cloudera::params::cm_yumserver,
  $cm_yumpath     = $cloudera::params::cm_yumpath,
  $cm_version     = $cloudera::params::cm_version,
  $ci_yumserver   = $cloudera::params::ci_yumserver,
  $ci_yumpath     = $cloudera::params::ci_yumpath,
  $ci_version     = $cloudera::params::ci_version,
  $cm_server_host = $cloudera::params::cm_server_host,
  $cm_server_port = $cloudera::params::cm_server_port
) inherits cloudera::params {
  # Validate our booleans
  validate_bool($autoupgrade)
  validate_bool($service_enable)

  anchor { 'cloudera::begin': }
  anchor { 'cloudera::end': }

  class { 'cloudera::repo':
    ensure        => $ensure,
    cdh_yumserver => $cdh_yumserver,
    cm_yumserver  => $cm_yumserver,
    ci_yumserver  => $ci_yumserver,
    cdh_yumpath   => $cdh_yumpath,
    cm_yumpath    => $cm_yumpath,
    ci_yumpath    => $ci_yumpath,
    cdh_version   => $cdh_version,
    cm_version    => $cm_version,
    ci_version    => $ci_version,
#    require       => Anchor['cloudera::begin'],
#    before        => Anchor['cloudera::end'],
  }
  class { 'cloudera::java':
    ensure      => $ensure,
    autoupgrade => $autoupgrade,
  }
  class { 'cloudera::cdh':
    ensure         => $ensure,
    autoupgrade    => $autoupgrade,
    service_ensure => $service_ensure,
#    service_enable => $service_enable,
    require        => Class['cloudera::repo'],
#    require        => Anchor['cloudera::begin'],
#    before         => Anchor['cloudera::end'],
  }
  class { 'cloudera::cm':
    ensure         => $ensure,
    autoupgrade    => $autoupgrade,
    service_ensure => $service_ensure,
#    service_enable => $service_enable,
    server_host    => $cm_server_host,
    server_port    => $cm_server_port,
    require        => [ Class['cloudera::repo'], Class['cloudera::cdh'], ],
#    require        => Anchor['cloudera::begin'],
#    before         => Anchor['cloudera::end'],
  }

  Anchor['cloudera::begin'] ->
  Class['cloudera::repo'] ->
  Class['cloudera::java'] ->
  Class['cloudera::cdh'] ->
  Class['cloudera::cm'] ->
  Anchor['cloudera::end']
}
