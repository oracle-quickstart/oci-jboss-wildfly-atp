## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  lb_count             = var.add_load_balancer == true ? 1 : 0
  http_listener_count  = var.add_load_balancer && var.use_http ? 1 : 0
  https_listener_count = var.add_load_balancer && var.use_https && var.use_lb_termination ? 1 : 0
  tcp_listener_count   = var.add_load_balancer && var.use_https && !var.use_lb_termination ? 1 : 0
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}

resource "oci_load_balancer_load_balancer" "jboss_loadbalancer" {
  count = local.lb_count
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = var.compartment_id

  subnet_ids = var.subnet_ids

  display_name = var.name
  is_private   = var.is_private
  defined_tags = var.defined_tags
}

resource "oci_load_balancer_backend_set" "http_backendset" {
  count            = local.http_listener_count
  name             = "${var.backendset_name}-http"
  load_balancer_id = join(",", oci_load_balancer_load_balancer.jboss_loadbalancer[*].id)
  policy           = var.policy

  health_checker {
    port              = var.http_server_port
    protocol          = "HTTP"
    url_path          = var.health_check_path
    return_code       = var.return_code
    interval_ms       = var.health_check_interval_ms
    timeout_in_millis = var.health_check_timeout_ms
  }
}

resource "oci_load_balancer_listener" "http_listener" {
  count                    = local.http_listener_count
  load_balancer_id         = join(",", oci_load_balancer_load_balancer.jboss_loadbalancer[*].id)
  name                     = "http"
  default_backend_set_name = join(",", oci_load_balancer_backend_set.http_backendset[*].name)
  port                     = var.http_listener_port
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = 10
  }
}

resource "oci_load_balancer_backend" "http_backend" {
  count            = local.http_listener_count > 0 ? var.num_instances : 0
  load_balancer_id = join(",", oci_load_balancer_load_balancer.jboss_loadbalancer[*].id)
  backendset_name  = join(",", oci_load_balancer_backend_set.http_backendset[*].name)
  ip_address       = var.instance_private_ips[count.index]
  port             = var.http_server_port
  backup           = false
  drain            = false
  offline          = false
  weight           = var.policy_weight
}

resource "oci_load_balancer_backend_set" "tcp_ssl_backendset" {
  count            = local.tcp_listener_count
  name             = "${var.backendset_name}-tcp-ssl"
  load_balancer_id = join(",", oci_load_balancer_load_balancer.jboss_loadbalancer[*].id)
  policy           = var.policy

  health_checker {
    port              = var.https_server_port
    protocol          = "TCP"
    url_path          = var.health_check_path
    return_code       = var.return_code
    interval_ms       = var.health_check_interval_ms
    timeout_in_millis = var.health_check_timeout_ms
  }
}

resource "oci_load_balancer_listener" "tcp_ssl_listener" {
  count                    = local.tcp_listener_count
  load_balancer_id         = join(",", oci_load_balancer_load_balancer.jboss_loadbalancer[*].id)
  name                     = "tcp-ssl"
  default_backend_set_name = join(",", oci_load_balancer_backend_set.tcp_ssl_backendset[*].name)
  port                     = var.https_listener_port
  protocol                 = "TCP"

  connection_configuration {
    idle_timeout_in_seconds = 10
  }
}

resource "oci_load_balancer_backend" "tcp_ssl_backend" {
  count            = local.tcp_listener_count > 0 ? var.num_instances : 0
  load_balancer_id = join(",", oci_load_balancer_load_balancer.jboss_loadbalancer[*].id)
  backendset_name  = join(",", oci_load_balancer_backend_set.tcp_ssl_backendset[*].name)
  ip_address       = var.instance_private_ips[count.index]
  port             = var.https_server_port
  backup           = false
  drain            = false
  offline          = false
  weight           = var.policy_weight
}
