# Workspace Templates

Workspace Service Templates are located in this folder. We make use of our own custom user resource templates, this is where you can find those templates.

| VM type | Template name | Description |
| --- | --- | --- |
| Linux   | tre-service-guacamole-linuxvm-ouh2    | This is based on Ubuntu 22.04 with certain software pulled in via package manager |
| Windows | tre-service-guacamole-windowsvm-ouh2  | This is a custom Windows image for OUH use |

## Available VM sizes

| vCPU | RAM (GB) | GPU        | GPU Memory (GB) | CPU Type | Azure Series | Use Case                              | Price/Hour |
| ---- | -------- | ---------- | --------------- | -------- | ------------ | ------------------------------------- | ---------- |
| 2    | 4        | None       | -               | Intel    | B-Series     | Basic development/coding              | £0.05      |
| 2    | 8        | None       | -               | Intel    | Dsv5         | Data preprocessing/analysis           | £0.15      |
| 4    | 16       | None       | -               | Intel    | Dsv5         | ML data preparation                   | £0.30      |
| 4    | 16       | None       | -               | AMD      | D4as_v5      | ML data preparation                   | £0.30      |
| 4    | 16       | None       | -               | Intel    | F4s_v2       | CPU-intensive ML tasks                | £0.30      |
| 8    | 32       | None       | -               | Intel    | Dsv5         | Large dataset processing              | £0.65      |
| 8    | 64       | None       | -               | AMD      | Easv4        | Memory-intensive ML workloads         | £0.75      |
| 16   | 64       | None       | -               | Intel    | Dsv5         | Complex data analysis                 | £1.25      |
| 6    | 55       | 1/6 A10    | 4               | AMD      | NVadsA10_v5  | Small ML model training/inference     | £0.61      |
| 12   | 110      | 1/3 A10    | 8               | AMD      | NVadsA10_v5  | Medium ML model training              | £1.22      |
| 18   | 220      | 1/2 A10    | 12              | AMD      | NVadsA10_v5  | Advanced ML model training            | £2.05      |
| 6    | 112      | 1 V100     | 16              | Intel    | NC6s_v3      | Legacy AI/ML training (retiring)      | £3.21      |
| 36   | 440      | 1 A10      | 24              | AMD      | NVadsA10_v5  | Large ML model training               | £4.11      |
| 24   | 220      | 1 A100     | 80              | AMD      | NC_A100_v4   | High-end AI/deep learning training    | £4.14      |
| 12   | 224      | 2 V100     | 32              | Intel    | NC12s_v3     | Legacy multi-GPU training (retiring)  | £6.42      |
| 40   | 320      | 1 H100 NVL | 94              | AMD      | NCadsH100_v5 | LLM training/cutting-edge AI research | £7.70      |
| 48   | 440      | 2 A100     | 160             | AMD      | NC_A100_v4   | Multi-GPU deep learning training      | £8.29      |
| 96   | 880      | 4 A100     | 320             | AMD      | NC_A100_v4   | Large-scale neural network training   | £16.60     |
  
## Current VM Image options

### Windows

- Windows 10
- Windows 11
- OUH Server 2019 Data Science VM

### Linux

- Ubuntu 22.04 LTS
- OUH Ubuntu 22.04 Data Science VM

## Customising the user resources

The `guacamole-azure-linuxvm` and `guacamole-azure-windowsvm` folders follow a consistent layout.
To update one of these templates (or to create a new template based on these folders) to use different image details or VM sizes, there are a few files that need to be updated:

| File |  Description |
| ---- | ------------ |
| `porter.yaml`          | This file describes the template and the name should be updated when creating a template based on the folder. This file also contains a `custom` data section that describes the VM properties. Additionally, the version needs to be updated to deploy an updated version |
| `template_schema.json` | This file controls the validation applied to the template, for example specifying the valid options for fields such as size and image                                                                                                                                              |

### Configuration

In `porter.yaml`, the `custom` section contains a couple of sub-sections (shown below)

```yaml
custom:
  # For information on vm_sizes and image_options, see README.me in the guacamole/user-resources folder
  vm_sizes:
    "2 CPU | 4GB RAM | Text editing | £0.05 / hour": Standard_B2s
    "2 CPU | 8GB RAM | £0.10 / hour": Standard_D2s_v5
    "4 CPU | 16GB RAM | £0.20 / hour": Standard_D4s_v5
    "8 CPU | 32GB RAM | £0.35 / hour": Standard_D8s_v5
    "8 CPU | 64GB RAM | £0.45 / hour": Standard_E8as_v4
    "16 CPU | 64GB RAM | £0.65 / hour": Standard_D16s_v5
    "6 CPU - 112GB RAM | 1 V100 GPU - 16GB RAM | £3 / hour": Standard_NC6s_v3
    "12 CPU - 224GB RAM | 2 V100 GPU - 32GB RAM | £6 / hour": Standard_NC12s_v3
    "6 CPU - 55GB RAM | 1 A10 GPU - 4GB RAM | £0.45 / hour": Standard_NV6ads_A10_v5
  image_options:
    "Ubuntu 22.04 LTS":
      source_image_reference:
        publisher: canonical
        offer: 0001-com-ubuntu-server-jammy
        sku: 22_04-lts-gen2
        version: latest
        apt_sku: 22.04
      install_ui: true
      conda_config: true
      r_config: false
      docker_config: false
      secure_boot_enabled: true
      vtpm_enabled: true
    "OUH Ubuntu 22.04 Data Science VM":
      source_image_name: imgdef-linux-vm-custom
      install_ui: true
      conda_config: true
      r_config: true
      docker_config: true
      secure_boot_enabled: true
      vtpm_enabled: true
    # "Custom Image From Gallery":
    #   source_image_name: your-image
    #   install_ui: true
    #   conda_config: true
    #   secure_boot_enabled: true
    #   vtpm_enabled: true
```

The `vm_sizes` section is a map of a custom SKU description to the SKU identifier.

The `image_options` section defined the possible image choices for the template (note that the name of the image used here needs to be included in the corresponding enum in `template_schema.json`).

Within the image definition in `image_options` there are a few properties that can be specified:

| Name                     | Description                                                                                              |
| ------------------------ | -------------------------------------------------------------------------------------------------------- |
| `source_image_name`      | Specify VM image to use by name (see notes below for identifying the image gallery containing the image) |
| `source_image_reference` | Specify VM image to use by `publisher`, `offer`, `sku` & `version` (e.g. for Azure Marketplace images)   |
| `install_ui`             | (Linux only) Set `true` to install desktop environment                                                   |
| `conda_config`           | Set true to configure conda                                                                              |
| `secure_boot_enabled`    | Set true to enable [Secure Boot](https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch#secure-boot).  Requires a Requires a [Gen 2](https://learn.microsoft.com/en-us/azure/virtual-machines/generation-2) VM image |
| `vtpm_enabled`           | Set true to enable [Secure Boot](https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch#vtpm).  Requires a [Gen 2](https://learn.microsoft.com/en-us/azure/virtual-machines/generation-2) VM image |

When specifying images using `source_image_name`, the image must be stored in an [image gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/azure-compute-gallery).
To enable re-using built user resource templates across environments where the image may vary, the image gallery is configured via the `RP_BUNDLE_VALUES` environment variable when deploying the TRE.
The `RP_BUNDLE_VALUES` variable is a JSON object, and the `image_gallery_id` property within it identifies the image gallery that contains the images specified by `source_image_name`:

```bash
RP_BUNDLE_VALUES='{"image_gallery_id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<your-rg>/providers/Microsoft.Compute/galleries/<your-gallery-name>"}
```
