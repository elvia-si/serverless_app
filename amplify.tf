resource "aws_amplify_app" "my_web_app" {
  name       = "my-first-serverless-app"
  repository = "https://github.com/elvia-si/serverless_app"
  access_token = var.access_token

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 1
    frontend:
        phases:
            # IMPORTANT - Please verify your build commands
            build:
                commands: []
        artifacts:
            # IMPORTANT - Please verify your build output directory
            baseDirectory: /
            files:
                - '**/*'
        cache:
            paths: 
                - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

#   environment_variables = {
#     ENV = "test"
#   }

   enable_auto_branch_creation = true

  # The default patterns added by the Amplify Console.
  auto_branch_creation_patterns = [
    "*",
    "*/**",
  ]

  auto_branch_creation_config {
    # Enable auto build for the created branch.
    enable_auto_build = true
  }
}

resource "aws_amplify_branch" "development" {
  app_id      = aws_amplify_app.my_web_app.id
  branch_name = "development"
  stage     = "DEVELOPMENT"
}
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.my_web_app.id
  branch_name = "main"
  stage     = "PRODUCTION"
}

resource "aws_amplify_branch" "feature" {
  app_id      = aws_amplify_app.my_web_app.id
  branch_name = "static-web"
  stage     = "BETA"
}