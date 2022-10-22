data "template_file" "user_data" {
  template = file("${path.module}/users.yml")
}

output "rendered" {
  value = data.template_file.user_data.rendered
}

