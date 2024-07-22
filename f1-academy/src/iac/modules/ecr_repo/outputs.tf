output "ecr_repo" {
  value = aws_ecr_repository.f_one_academy_scrape_repo
}

output "repository_url" {
  value = aws_ecr_repository.f_one_academy_scrape_repo.repository_url
}