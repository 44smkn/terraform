tfmigrate {
  migration_dir = "./tfmigrate"
  history {
    storage "s3" {
      bucket = "v1-44smkn-terraform-state"
      key    = "aws/eks/history.json"
    }
  }
}
