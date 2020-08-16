module "key_pair_1" {
  source = "./key-pair"
  student_alias = var.student_alias
  id = "parent"
}

module "key_pair_2" {
  source = "./key-pair"
  student_alias = var.student_alias
  id = "${module.key_pair_1.key_pair_id}-child"
}
