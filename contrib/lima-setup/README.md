# lima-setup

lima-setup is a straightforward wrapper logic for <https://lima-vm.io/> to Kubespray-Contributor which works with ARM64 Apple devices.

## Initialize environment

```bash
./contrib/lima-setup/setup.sh create <ControlPlaneNodeCount> <WorkerNodeCount>
```

### Example of a setup with 1 ControlPlane Node and 2 Worker Nodes

```bash
./contrib/lima-setup/setup.sh create 1 2
ansible-playbook -i contrib/lima-setup/inventory/inventory.ini --become cluster.yml
```

## Rebuild environment

If you have already created an environment with the `lima-setup/setup.sh`` script, you can use the rebuild-environment.sh script to discard the VMs and regenerate them.

```bash
./contrib/lima-setup/rebuild-environment.sh
```
