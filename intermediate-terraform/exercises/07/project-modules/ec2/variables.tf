variable "keys" {
  type = list(object({
    name        = string
    public_key  = string
  }))
}
