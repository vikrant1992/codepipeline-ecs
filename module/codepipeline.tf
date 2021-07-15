# CodeBuild Section for the build stage
resource "aws_codebuild_project" "build_project" {
  name           = "${var.repo_name}-test"
  description    = "The CodeBuild project for ${var.repo_name}"
  service_role   = "${aws_iam_role.codebuild_assume_role.arn}"
  build_timeout  = "5"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "${var.build_compute_type}"
    image           = "${var.build_image}"
    type            = "LINUX_CONTAINER"
    privileged_mode = "${var.build_privileged_override}"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${var.test_buildspec}"
  }
}



#code pipeline

resource "aws_codepipeline" "default" {
  name     = "${var.name}-codepipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${var.artifact_bucket_name}"
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = 1
      run_order        = 1
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.repo_name
        BranchName     = var.repo_default_branch
      }
    }
  }


  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      run_order        = 1
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName   = aws_codebuild_project.build_project.name
        PrimarySource = "Source"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      run_order        = 1
      input_artifacts  = ["build_output"]
      output_artifacts = ["deploy_output"]

      configuration = {
        ProjectName = "${var.project_name}"
        PrimarySource = "Source"
      }
    }
  }
}

