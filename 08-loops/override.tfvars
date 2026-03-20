services = {
  web     = { image = "nginx:alpine", port = 8080 }
  api     = { image = "nginx:alpine", port = 8081 }
  admin   = { image = "nginx:alpine", port = 8082 }
  metrics = { image = "nginx:alpine", port = 8083 }
}
