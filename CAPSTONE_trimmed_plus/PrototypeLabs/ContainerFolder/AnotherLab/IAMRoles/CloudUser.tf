# creating the user to have a unique id upon creation
resource "random_id" "hex" {
  byte_length = 4
}

# all this lab needs is user and assigned permissions to create a role
resource "aws_iam_user" "cloud_user" {
  name = "cloud-user-${random_id.hex.hex}"
}
