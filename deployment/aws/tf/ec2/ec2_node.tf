resource "aws_iam_instance_profile" "node_ec2_profile" {
  name = "node_ec2_profile"
  role = "${aws_iam_role.node_ec2_role.name}"
}

resource "aws_iam_role_policy" "node_ec2_role_policy" {
  name = "node_ec2_role_policy"
  role = "${aws_iam_role.node_ec2_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_instance" "node_ec2_role" {
  ami = "ami-0bbe6b35405ecebdb"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.node_ec2_profile.name}"
  key_name = "mytestpubkey"
}