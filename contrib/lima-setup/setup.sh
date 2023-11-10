#!/usr/bin/env bash

# This script gets two arguments:
# 1. create or delete
# 1. the count of control-plane nodes
# 2. the count of worker nodes

PREFIX="kubespray"
CONTROL_PLANE=$PREFIX-"control-plane"
WORKER=$PREFIX-"worker"

# define create and delete functions
function create {
    echo "Creating the cluster"
    # create the control-plane nodes

    for i in $(seq 1 "$1"); do
        echo "Creating control-plane node $i"
        limactl start --tty=false --plain --network=lima:user-v2 --name="$CONTROL_PLANE"-"$i" template://ubuntu-lts
    done

    # create the worker nodes
    for i in $(seq 1 "$2"); do
        echo "Creating worker node $i"
        limactl start --tty=false --plain --network=lima:user-v2 --name="$WORKER"-"$i" template://ubuntu-lts
    done

    create_ansible_inventory
}

function get_cp_nodes {
    # get the control-plane nodes from lima
    limactl list --format '{{ .Name }} ansible_port={{ .SSHLocalPort }} ansible_host=127.0.0.1' | grep "$CONTROL_PLANE"
}

function get_wk_nodes {
    limactl list --format '{{ .Name }} ansible_port={{ .SSHLocalPort }} ansible_host=127.0.0.1' | grep "$WORKER"
}

function create_ansible_inventory {
    GIT_ROOT_PATH=$(git rev-parse --show-toplevel)
    echo "Creating the Ansible inventory file"
    # create the Ansible inventory file
    echo "[all]" > "$GIT_ROOT_PATH"/contrib/lima-setup/inventory/inventory.ini
    {
        get_cp_nodes
        get_wk_nodes
        echo "[kube_control_plane]"
        get_cp_nodes
        echo "[etcd]"
        get_cp_nodes
        echo "[kube_node]"
        get_wk_nodes
        echo "[calico_rr]"
        echo "[k8s_cluster:children]"
        echo "kube_control_plane"
        echo "kube_node"
        echo "calico_rr"
     } >> "$GIT_ROOT_PATH"/contrib/lima-setup/inventory/inventory.ini

}

function delete {
    echo "Deleting the cluster"
    # delete the control-plane nodes
    for i in $(seq 1 "$1"); do
        echo "Deleting control-plane node $CONTROL_PLANE-$i"
        limactl stop "$CONTROL_PLANE"-"$i"
        limactl delete "$CONTROL_PLANE"-"$i"
    done

    # delete the worker nodes
    for i in $(seq 1 "$2"); do
        echo "Deleting worker node $i"
        limactl stop "$WORKER"-"$i"
        limactl delete "$WORKER"-"$i"
    done
}

# check if the first argument is create or delete
if [ "$1" != "create" ] && [ "$1" != "delete" ]; then
    echo "The first argument must be create or delete"
    exit 1
fi

# check if the second argument is a number
if ! [[ "$2" =~ ^[0-9]+$ ]]; then
    echo "The second argument must be a number"
    exit 1
fi

# check if the third argument is a number
if ! [[ "$3" =~ ^[0-9]+$ ]]; then
    echo "The third argument must be a number"
    exit 1
fi

# iterate over the arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        create)
            create "$2" "$3"
            shift
            ;;
        delete)
            delete "$2" "$3"
            shift
            ;;
        *)
            echo "Unknown argument: $key"
            exit 1
            ;;
    esac
done


