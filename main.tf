module "codepipeline" {
    source = "./module"
    repo_name = "uni-poc"
    name  = "uni"
    project_name = "personal"
    artifact_bucket_name = "vikrant-eks-sanbox"
    test_buildspec = "buildspec-build.yml"
    build_privileged_override = true
}