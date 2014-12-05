# Puppet for Hackers course module by James
# Copyright (C) 2013-2014+ James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# README: this is a module built for use with: Oh My Vagrant!

class p4h::lesson15() {

  file { '/root/README':
    content => "##lesson15
For this lesson, please do the following:
* Read the 'Hybrid Management' blog post I wrote about this subject
** https://ttboj.wordpress.com/2014/07/24/hybrid-management-of-freeipa-types-with-puppet/
* Try to understand this technique and follow the code
** Try to understand what the $type_excludes do
*** Realize that this uses an extended, more complex form of clean.sh.erb
** Try to understand the difference between $watch and $modify
*** Don't feel bad about this, I forget which is which sometimes too :)
* IMHO, this is a critical technique for keeping the harmony at Red Hat
** This way different product teams can have their UI's and I can have my glue!

Bonus:
* There's no bonus, all patches that are correct take you to 'Level 42'
** (Don't pass go, go directly to 'Level 42')

Level 42:
* Patch puppet-ipa so that it accepts creation time exclusions
** It will be useful if you look at this for reference:
*** https://www.redhat.com/archives/freeipa-devel/2014-July/msg00349.html
* Write a generalized clean.sh.erb, that is lib-ified and in python :)
* Think of an idea for additional exclusionary criteria

Happy hacking!\n",
  }

  include stdlib

  class managed_users ($users) {
    # helper variables
    $stored_users_on_node = split($p4h_managed_users_list, ';')
    $users_for_deletion = difference($stored_users_on_node, $users)

    # simulation of a database, e,g, FreeIPA on the node
    $service_db = "/tmp/a-service-users-db"

    # db_definition
    file { $service_db:
      ensure => directory
    }

    # has to have bot ensure/absent paths
    define a_service_user($ensure) {
      file { "${::p4h::lesson15::managed_users::service_db}/${name}":
        ensure  => $ensure,
        content => 'puppet managed',
        require => File["${::p4h::lesson15::managed_users::service_db}"]
      }
    }

    # ensure all the managed users are there, as usual
    if !empty($users) {
      a_service_user { $users: ensure => present }
    }
    # delete removed users which are no longer managed
    if !empty($users_for_deletion) {
      a_service_user { $users_for_deletion: ensure => absent }
    }

    # DEBUG output
    notify { managed_users: message => join($users,',') } ->
    notify { stored_users: message => join($stored_users_on_node,',') } ->
    notify { to_delete: message => join($users_for_deletion,',') }
  }

  # this is the definition of managed users
  class { 'managed_users':
    # CHANGE the array to see users added and removed automaticaly form the node
    users => ['a','b','c']
  }

}

# vim: ts=8
