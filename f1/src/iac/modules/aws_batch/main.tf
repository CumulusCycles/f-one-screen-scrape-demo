module "batchIAM" {
  source               = "./modules/iam"
  bucket_name          = var.bucket_name
  resource_name_prefix = var.resource_name_prefix
  batch_iam_role_path  = var.batch_iam_role_path
  ecs_iam_role_path    = var.ecs_iam_role_path
}

module "awsBatch" {
  source               = "./modules/batch"
  resource_name_prefix = var.resource_name_prefix
  image_uri            = var.image_uri
  port                 = var.port

  batch_iam_role_arn = module.batchIAM.batch_iam_role_arn
  ecs_iam_role_arn   = module.batchIAM.ecs_iam_role_arn

  depends_on = [module.batchIAM]
}
