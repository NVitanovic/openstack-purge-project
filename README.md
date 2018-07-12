# openstack-purge-project
Removes all associated resources (instances, ips, routers, networks, etc.) from Openstack project and deletes the empty project.

Other option allows to delete all projects except a few on the list.

## Idea
The idea behind the script is to purge all resources and delete a project in OpenStack.

## Pre requirements
1. You need to install *ospurge*. [More info here](https://github.com/openstack/ospurge).
2. You also need *openstack-cli* installed. [More info here](https://docs.openstack.org/mitaka/user-guide/common/cli_install_openstack_command_line_clients.html).

## Usage
### Delete single project
`./openstack-purge-project.sh --single <project_id/name>`

### Delete all projects (except admin and services)
`./openstack-purge-project.sh --all`

### Show help
`./openstack-purge-project.sh --help`
