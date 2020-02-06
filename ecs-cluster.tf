resource "aws_ecs_cluster" "medici-dev" {
  name = "medici-dev"
  setting
    name  = containerInsights
    value = enabled
}


# Simply specify the family to find the latest ACTIVE revision in that family.
data "aws_ecs_task_definition" "medici-server" {
  task_definition = "${aws_ecs_task_definition.mongo.family}"
}

resource "aws_ecs_task_definition" "mongo" {
  family = "mongodb"

  container_definitions = <<DEFINITION
[
  {
    "cpu": 128,
    "environment": [{
      "name": "SECRET",
      "value": "KEY"
    }],
    "essential": true,
    "image": "medici-server:latest",
    "memory": 128,
    "memoryReservation": 64,
    "name": "mongodb"
  }
]
DEFINITION
}

resource "aws_ecs_service" "medici-server" {
  name          = "medici-server"
  cluster       = "${aws_ecs_cluster.medici-server.id}"
  desired_count = 2

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.medici-server.family}:${max("${aws_ecs_task_definition.mongo.revision}", "${data.aws_ecs_task_definition.mongo.revision}")}"
}
