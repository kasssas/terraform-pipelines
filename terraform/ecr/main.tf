variable "repository_names" {
  description = "List of repository names to create"
  type        = list(string)
  default     = ["frontend", "backend"]
}

resource "aws_ecr_repository" "this" {
  count                = length(var.repository_names)
  name                 = var.repository_names[count.index]
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_urls" {
  value = aws_ecr_repository.this[*].repository_url
}
