variable "my_list" {
  type      = list(string)
  default   = ["1", "2", "3"]
}

variable "my_map" {
  type      = map
  default   = {names: ["John", "Susy", "Harold"], ages: [12, 14, 10]}
}

output "my_list_index_2" {
  value = "${var.my_list[2]}"
}

output "my_list_values" {
  value = "${var.my_list}"
}

output "my_map_values" {
  value = var.my_map # the ability to do this without quotes is new in 0.12!
}
