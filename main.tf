/**
 * ## Usage
 *
 * Creates a pipeline for EC2 Image Builder.
 *
 * ```hcl
 * module "image_builder_infrastructure_configuration" {
 *   source = "dod-iac/image-builder-infrastructure-configuration/aws"
 *   version = "1.0.0"
 *
 *   iam_instance_profile_name     = aws_iam_instance_profile.image_builder_instance_role.name
 *   logging_bucket                = var.logging_bucket
 *   name                          = format("app-%s-%s", var.application, var.environment)
 *   subnet_id                     = coalesce(var.subnet_ids...)
 *   vpc_id                        = var.vpc_id
 * }
 *
 * module "image_builder_pipeline" {
 *   source = "dod-iac/image-builder-pipeline/aws"
 *
 *   ami_name    = format(app-%s-%s-{{ imagebuilder:buildDate }}", var.application, var.environment)
 *   ami_regions = [data.aws_region.current.name]
 *   ami_tags = {
 *     "Automation" : "Terraform",
 *     "Project" : var.project,
 *     "Application" : var.application,
 *     "Environment" : var.environment,
 *   }
 *   base_image = format(
 *     "arn:%s:imagebuilder:%s:aws:image/red-hat-enterprise-linux-7-x86/x.x.x",
 *     data.aws_partition.current.partition,
 *     data.aws_region.current.name
 *   )
 *   components = flatten([
 *     [
 *       {
 *         arn = format(
 *           "arn:%s:imagebuilder:%s:aws:component/aws-cli-version-2-linux/1.0.3/1",
 *           data.aws_partition.current.partition,
 *           data.aws_region.current.name
 *         )
 *       }
 *     ],
 *     [
 *       {
 *         arn = module.image_builder_component.arn
 *       }
 *     ]
 *   ])
 *   name                         = format("app-%s-%s", var.application, var.environment)
 *   infrastructure_configuration = module.image_builder_infrastructure_configuration.arn
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_region" "current" {}

resource "aws_imagebuilder_image_recipe" "main" {
  name         = coalesce(var.recipe_name, var.name)
  version      = var.recipe_version
  parent_image = var.base_image
  tags         = var.tags

  dynamic "component" {
    for_each = var.components
    content {
      component_arn = component.value.arn
    }
  }
}

resource "aws_imagebuilder_distribution_configuration" "main" {
  name = var.name
  dynamic "distribution" {
    for_each = length(var.ami_regions) > 0 ? var.ami_regions : [data.aws_region.current.name]
    content {
      region = distribution.value
      ami_distribution_configuration {
        description = var.ami_description
        name        = coalesce(var.ami_name, format("%s-{{ imagebuilder:buildDate }}", var.name))
        ami_tags    = var.ami_tags
      }
    }
  }
}

resource "aws_imagebuilder_image_pipeline" "main" {
  description                      = var.description
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.main.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.main.arn
  infrastructure_configuration_arn = var.infrastructure_configuration
  name                             = var.name
  status                           = var.enabled ? "ENABLED" : "DISABLED"
  tags                             = var.tags

  dynamic "schedule" {
    for_each = length(var.schedule_expression) > 0 ? [1] : []
    content {
      pipeline_execution_start_condition = var.check_dependencies ? "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE" : "EXPRESSION_MATCH_ONLY"
      schedule_expression                = var.schedule_expression
    }
  }
}
