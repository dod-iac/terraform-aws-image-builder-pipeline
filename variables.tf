variable "ami_description" {
  type        = string
  description = "The description applied to the distributed AMI."
  default     = "An Amazon Machine Image (AMI) built with EC2 Image Builder."
}

variable "ami_name" {
  type        = string
  description = "The name of the distributed AMI.  Defaults to the name of the pipeline appended with \"-{{ imagebuilder:buildDate }}\"."
  default     = ""
}

variable "ami_regions" {
  type        = list(string)
  description = "A list of regions where the AMI will be distributed.  Defaults to current region."
  default     = []
}

variable "ami_tags" {
  type        = map(string)
  description = "The tags for the distributed AMI."
  default     = {}
}

variable "base_image" {
  type        = string
  description = "The ARN of the base image of the recipe."
}

variable "check_dependencies" {
  type        = bool
  description = "Only run pipeline at the scheduled time if components were updated."
  default     = false
}

variable "components" {
  type = list(object({
    arn = string
  }))
  description = "The ordered components of the recipe."
}

variable "enabled" {
  type        = bool
  description = "Is the pipeline enabled."
  default     = true
}

variable "description" {
  type        = string
  description = "The description of the pipeline."
  default     = "A pipeline for EC2 Image Builder."
}

variable "infrastructure_configuration" {
  type        = string
  description = "The ARN of the infrastructure configuration to use with this pipeline."
}

variable "name" {
  type        = string
  description = "The name of the pipeline."
}

variable "recipe_name" {
  type        = string
  description = "The name of the recipe.  Defaults to the name of the pipeline."
  default     = ""
}

variable "recipe_version" {
  type        = string
  description = "The version of the EC2 Image Builder recipe."
  default     = "1.0.0"
}

variable "schedule_expression" {
  type        = string
  description = "Cron expression of how often the pipeline is executed."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "The tags applied to the recipe and pipeline."
  default     = {}
}
