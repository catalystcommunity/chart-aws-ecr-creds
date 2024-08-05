# AWS ECR Creds Helm Chart

When using ECR in not-aws, you need credentials in your imagePullSecrets. Those require an aws cli command, `aws ecr get-login-password` run with credentials, to get a token that lasts 12 hours.

This runs a cron job every N minutes (default 240 minutes or 4 hours) and replaces the token in secrets in every namespace minus exceptions.

## TL;DR;

```console
$ helm repo add catalystcommunity https://raw.githubusercontent.com/catalystcommunity/charts/main
$ helm install my-release catalystcommunity/aws-ecr-creds -n [namespace] \
  --set-string aws.account=<aws account nubmer> \
  --set aws.region=<aws region> \
  --set aws.accessKeyId=<base64> \
  --set aws.secretAccessKey=<base64> \
```

## Introduction

This chart is meant to take any non-AWS Kubernetes cluster and give it access to ECR in an account. You will need to make an IAM user with whatever limits you want, but the ECR Read Only policy managed by AWS is probably good enough. Get an access Key Id and Secret Key and inject how you will.

This should run in its own namespace and copy from there _to other_ namespaces, which limits RBAC problems. By default it will deploy to the `catalyst-aws-creds` namespace. If you need multiple, you can override the creds secret name used.

This chart is heavily influenced by Bitnami charts best practices.

Inspired by architectminds/aws-ecr-credential but that chart was severely limited for our needs

## Prerequisites

- Kubernetes 1.21+
- Helm 3.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add catalystcommunity https://raw.githubusercontent.com/catalystcommunity/charts/main
$ # If you don't have the namespace to deploy this to already, you need to create it with --create-namespace added
$ helm install my-release catalystcommunity/aws-ecr-creds -n [namespace] \
  --set-string aws.account=<aws account nubmer> \
  --set aws.region=<aws region> \
  --set aws.accessKeyId=<base64> \
  --set aws.secretAccessKey=<base64> \
```

These commands deploy aws-ecr-creds on the Kubernetes cluster in the default configuration with required fields added. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm ls -n [namespace]`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm del my-release -n [namespace]
```

The command removes all the Kubernetes components associated with the chart and deletes the release. It does NOT delete created secrets, though they should expire within 12 hours

## Parameters

The following table lists the configurable parameters of the Typesense chart and their default values.

| Parameter                               | Description                                                                 | Default                                                 |
|-----------------------------------------|-----------------------------------------------------------------------------|---------------------------------------------------------|
| `image`                                 | URL for the image to run                                                    | `quay.io/catalystcommunity/catalyst-aws-kube-image`         |
| `imageTag`                              | Tag for the image                                                           | `latest`                                                |
| `namespaceOverride`                     | Namespace to install things to if not using --namespace in the helm command | `aws-ecr-creds`                                         |
| `aws.account`                           | Account number of the AWS account for the ECR repos                         | `""`                                                    |
| `aws.region`                            | Region the ECR repos are hosted in                                          | `""`                                                    |
| `aws.accessKeyId`                       | Access Key ID for the user to access ECR creds with                         | `nil`                                                   |
| `aws.secretAccessKey`                   | Secret Access Key for the user to access ECR creds with                     | `nil`                                                   |
| `serviceAccount.create`                 | Whether or not to create the serviceAccount to use (if you manage this)     | `true`                                                  |
| `secretName`                            | The name of the secret for this release to manage (minus -secret)           | `aws-ecr-creds`                                         |
| `cronSchedule`                          | A cron compatible schedule, defaulting to every 4 hours                     | `* */4 * * *`                                           |
| `namespaceExceptions`                   | A default list of namespace exceptions, avoid overriding                    | see chart values.yaml                                   |
| `additionalNamespaceExceptions`         | Additional namespaces to not copy the creds secret to                       | []                                                      |


## Configuration and installation details

### AWS settings

The AWS settings of `account`, `region`, `accessKeyId`, and `secretAccessKey` are required. `account` and `region` can be specified in a values.yaml file. `accessKeyId` and `secretAccessKey` should be specified on the command or through other secret injection methods in your chosen tool, like ArgoCD

The IAM user associated with this key set is only required to have read-only access to ECR.

### Namespace Exceptions 

The `namespaceExceptions` value should not be changed unless you need the secret in things like the `default` namespace. This should feel bad because you should never have anything in `default`, but you might need something in `kube-system` for an edge case.

Use `additionalNamespaceExceptions` to add more exceptions to the list. If you need the opposite behavior, we don't support that at this time, but we could be talked to about a PR. Don't do the PR work before chatting. You can also simply fork this, it's open source.

## Contributing

We accepts PRs from just about anyone if they have been discussed beforehand and they meet our review. There are no other requirements.

