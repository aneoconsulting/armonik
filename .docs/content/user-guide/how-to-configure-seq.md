# How to configure SEQ?

If you want to access outside your Kubernetes cluster, you have to configure Seq to make it accessible from the outside.
Edit the [parameters.tfvars](https://github.com/aneoconsulting/ArmoniK/blob/main/infrastructure/quick-deploy/localhost/parameters.tfvars), and edit the `seq` section (or add it if not present). Add the `service_type` option:

```hcl
seq = {
  service_type = "LoadBalancer"
}
```

Then, redeploy.

## Connexion

When you perform the command:

```bash [shell]
kubectl get svc -n armonik
```

You should see a service called `seqweb`. You can connect to its external-ip:8080 in your browser to access seq.

If you enabled the authentication of seq, the default credentials are the following:
- Username: `admin`
- Password: `admin`

You can then change the password in `settings` -> `system`.

## Useful requests

The application name for the control plane is `ArmoniK.Control`. (Application = 'ArmoniK.Control')
The application name for the polling agent is `ArmoniK.Compute.PollingAgent`. (Application = 'ArmoniK.Compute.PollingAgent')
The application name for the worker is `ArmoniK.Compute.Worker`. (Application = 'ArmoniK.Compute.Worker')

## Troubleshoot

If you use docker as the Kubernetes backend, you should configure the logging driver of docker to `json-file`.
Otherwise, the logs will remain empty (fluent-bit will not be able to fetch logs).

<https://docs.docker.com/config/containers/logging/configure/#configure-the-default-logging-driver>
<https://rancher.com/docs/rancher/v2.0-v2.4/en/cluster-admin/tools/cluster-logging/>
