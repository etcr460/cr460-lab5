provider "google" {
  credentials = "${file("../account.json")}"
  project     = "cr460-1"
//  region      = "us-central1"
  region      = "us-east1"
}


