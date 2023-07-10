# Random Kubernetes Deployments

This is a set of scripts to create Kubernetes deployments that have random requests and limits.
It allows you to provide a deployment template and then create workloads based on it.
These scripts were designed to demo [karpenter](https://karpenter.sh) but you can use them by providing your own templates.

These tools were used to create demos like the one found here
[![](/img/og-image.jpg)](https://www.youtube.com/shorts/xvUSnzGY7yU)

## Scripts

### create-workloads.sh

[`create-workloads.sh`](./create-workloads.sh) creates deployments

example

```
# create 1000 pods using deployments 
# with 250 replicas each
# use fast.template.yaml

create-workloads.sh \
  -t 1000 \
  -b 250 \
  -f fast-template.yaml
```

### delete-workloads.sh

[`delete-workloads.sh`](./delete-workloads.sh) deletes deployments
This will delete all deployments.
**Use with caution.**

Optional arguments are passed to kubectl

examples

```
delete-workloads.sh
```

delete workloads in a namespace

```
delete-workloads.sh -n default
```

### scale-deployments.sh

[`scale-deployments.sh`](./scale-deployments.sh) can randomly scale deployments up and down between 1-10 percent of existing deployment replicas.
It will scale all deployments with an optional sleep between scaling activities.
You can also set a scaling direction (up or down) to scale randomly in a single direction.

example

```
scale-deployments.sh
```

### roll-deployments.sh

[`roll-deployments.sh`](./roll-deployments.sh) will roll new versions of all the pods by changing metadata from the deployment without changing the requests or limits.
Rolls all deployments in the requested namespace.
**Use with caution.**

example

```
./roll-deployments.sh -n my-namespace
```

## Templates

The templates folder has various templates for deployments using host and AZ spread, GPU workloads, and other options.

For more Karpenter examples see the [karpenter examples](https://github.com/aws/karpenter/tree/main/examples/workloads).
