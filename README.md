# terraform-gke-ghost

This is an opinionated module to install [Ghost](https://ghost.org/) in Google Cloud/GKE.

## Infrastructure

You will need:
- Already existing MySQL instance you wish to use with Ghost
- Already existing backend configured for your Kubernetes cluster
- nginx ingress controller in Kubernetes
- terraform v0.12+
- Docker image you wish to use

This module will provision:
- An external IP
- Database in an existing Cloud SQL instance
- Cloud SQL user
- Kubernetes namespace and objects in an existing Kubernetes cluster
- Kubernetes Deployment
- Kubernetes Endpoint for the Database for use in other pods and services
- Load balancer and frontends for an already existing backend
- Storage bucket
- Custom Docker image with GCP Storage Adapter
- GCP managed certificate

## Docker Image

An example docker image is included

## Variables

|var|usage|
|---|-----|
|db_instance| Pre-existing database instance |
|db_password| Password you want for ghostcms user |
|db_ip| Expects internal IP of Cloud SQL database |
|mail_password| Password for mail service you plan to use |
|ghostimage| Location of docker image you want to use in Kubernetes |
|project| GCP project |
|zone| GCP zone |
|region| GCP region |
|backend_service_name|Existing backend service for frontends|
|ghost_envvars| Various env vars for Ghost |
|prefix| Used in object names, Kubernetes selectors, and Database names|

ghost_envvars example:
```
ghost_envvars = {
  url              = "https://<YOUR URL>"
  server__host     = "0.0.0.0"
  server__port     = "2368"
  NODE_ENV         = "production"
  logging__level   = "info"
  database__client = "mysql"

  mail__transport                 = "SMTP"
  mail__options__service          = "<YOUR SERVICE>"
  mail__options__host             = "<YOUR SMTP HOST>"
  mail__options__port             = "<YOUR SMTP PORT>"
  mail__options__auth__user       = "<YOUR SMTP USER>"
  mail__options__secureConnection = "<SET TO TRUE OR OMIT IF NOT USING 465>"
  storage__active                 = "gcloud"
  storage__gcloud__projectId      = "<YOUR GCP PROJECT>"
  storage__gcloud__assetDomain    = "<YOUR ASSET DOMAIN - LEAVE TRAILING SLASH>/"
  storage__gcloud__insecure       = false
  storage__gcloud__maxAge         = 3600
  storage__gcloud__key            = "/var/run/secrets/bucket/key.json"
}
```

Full example usage:

```
module "ghostblog" {
  source = "github.com/elijahsgh/terraform-gke-ghost"
  db_instance          = "<YOUR DB INSTANCE>"
  db_password          = "<YOUR DB PASSWORD>"
  db_ip                = "<YOUR DB IP>"
  zone                 = "<YOUR PROJECT ZONE>"
  region               = "<YOUR PROJECT REGION>"
  project              = "<YOUR PROJECT>"
  prefix               = "<PREFERRED PREFIX>"
  mail_password        = "<MAIL PASSWORD>"
  ghostimage           = "<IMAGE>"
  backend_service_name = "<BACKEND>"

  ghost_envvars = {
      <SEE ABOVE>
  }
}
```

## WARNING

Ghost will boot up waiting for an Admin user to be created. You should immediately create this user.

## GCP Managed Certificates Note

Certificates may take some time to provision. You should already have your DNS settings configured to expedite certificate provisioning. Failing to configure your DNS correctly can cause the managed certificate to not be provisioned which means your site will not be accessible.

## Additional Notes

Ghost does not support sharding or multiple instances.

This will most likely not work if you specify `http://` as your URL/proto.

Review and bug fixes welcome. I make no promises about addressing open issues at this time. :)

Use this module at your own risk. :)
