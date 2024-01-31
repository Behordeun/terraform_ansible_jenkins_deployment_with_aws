terraform {
  cloud {
    organization = "mtc_terransible_behordeun"

    workspaces {
      name = "terransible"
    }
  }
}
