provider "aws" {
  version = "~> 2.0"
}

data "aws_ami" "test" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
}

output "aws_ami_test_singleton" {
  value = "${data.aws_ami.test.id}"
}

output "aws_ami_test_list" {
  value = "${data.aws_ami.test[*].id}"
}

# the below will not work for the aws_ami data type because:
# the data source type aws_ami, according to failure output of terraform itself:
#     does not have "count" or "for_each" set, references
#     to it must not include an index key. Remove the bracketed index to refer to
#     the single instance of this resource.
#
# output "aws_ami_test_first_item" {
#   value = "${data.aws_ami.test[0].id}"
# }
