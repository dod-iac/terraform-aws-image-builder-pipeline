<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates a pipeline for EC2 Image Builder.

```hcl
module "image_builder_infrastructure_configuration" {
  source = "dod-iac/image-builder-infrastructure-configuration/aws"
  version = "1.0.0"

  iam_instance_profile_name     = aws_iam_instance_profile.image_builder_instance_role.name
  logging_bucket                = var.logging_bucket
  name                          = format("app-%s-%s", var.application, var.environment)
  subnet_id                     = coalesce(var.subnet_ids...)
  vpc_id                        = var.vpc_id
}

module "image_builder_pipeline" {
  source = "dod-iac/image-builder-pipeline/aws"

  ami_name    = format(app-%s-%s-{{ imagebuilder:buildDate }}", var.application, var.environment)
  ami_regions = [data.aws_region.current.name]
  ami_tags = {
    "Automation" : "Terraform",
    "Project" : var.project,
    "Application" : var.application,
    "Environment" : var.environment,
  }
  base_image = format(
    "arn:%s:imagebuilder:%s:aws:image/red-hat-enterprise-linux-7-x86/x.x.x",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )
  components = flatten([
    [
      {
        arn = format(
          "arn:%s:imagebuilder:%s:aws:component/aws-cli-version-2-linux/1.0.3/1",
          data.aws_partition.current.partition,
          data.aws_region.current.name
        )
      }
    ],
    [
      {
        arn = module.image_builder_component.arn
      }
    ]
  ])
  name                         = format("app-%s-%s", var.application, var.environment)
  infrastructure_configuration = module.image_builder_infrastructure_configuration.arn
}
```

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_imagebuilder_distribution_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource |
| [aws_imagebuilder_image_pipeline.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource |
| [aws_imagebuilder_image_recipe.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_recipe) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_description"></a> [ami\_description](#input\_ami\_description) | The description applied to the distributed AMI. | `string` | `"An Amazon Machine Image (AMI) built with EC2 Image Builder."` | no |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | The name of the distributed AMI.  Defaults to the name of the pipeline appended with "-{{ imagebuilder:buildDate }}". | `string` | `""` | no |
| <a name="input_ami_regions"></a> [ami\_regions](#input\_ami\_regions) | A list of regions where the AMI will be distributed.  Defaults to current region. | `list(string)` | `[]` | no |
| <a name="input_ami_tags"></a> [ami\_tags](#input\_ami\_tags) | The tags for the distributed AMI. | `map(string)` | `{}` | no |
| <a name="input_base_image"></a> [base\_image](#input\_base\_image) | The ARN of the base image of the recipe. | `string` | n/a | yes |
| <a name="input_check_dependencies"></a> [check\_dependencies](#input\_check\_dependencies) | Only run pipeline at the scheduled time if components were updated. | `bool` | `false` | no |
| <a name="input_components"></a> [components](#input\_components) | The ordered components of the recipe. | <pre>list(object({<br>    arn = string<br>  }))</pre> | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the pipeline. | `string` | `"A pipeline for EC2 Image Builder."` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Is the pipeline enabled. | `bool` | `true` | no |
| <a name="input_infrastructure_configuration"></a> [infrastructure\_configuration](#input\_infrastructure\_configuration) | The ARN of the infrastructure configuration to use with this pipeline. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the pipeline. | `string` | n/a | yes |
| <a name="input_recipe_name"></a> [recipe\_name](#input\_recipe\_name) | The name of the recipe.  Defaults to the name of the pipeline. | `string` | `""` | no |
| <a name="input_recipe_version"></a> [recipe\_version](#input\_recipe\_version) | The version of the EC2 Image Builder recipe. | `string` | `"1.0.0"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Cron expression of how often the pipeline is executed. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags applied to the recipe and pipeline. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the EC2 Image Builder pipeline. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
