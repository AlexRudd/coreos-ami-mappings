# coreos-ami-mappings
Bash script to fetch and update the AMI mappings of AWS CloudFormation templates

The latest mappings are taken from the [CoreOS website](https://coreos.com/os/docs/latest/booting-on-ec2.html)'s ami json feeds (https://coreos.com/dist/aws/aws-`<channel>`.json)

## Usage

Show usage prompt:

```bash
updateami.sh -h
updateami.sh --help
```
---

Output only the updated AMI mappings without changing any files (defaults to stable ami channel feed):

```bash
updateami.sh -m
updateami.sh --map
```

---

Choose a channel to get AMI mappings from (stable, beta, or alpha)

```bash
updateami.sh stable -m
updateami.sh beta -m
updateami.sh alpha -m
```

---

Replace the AMI mappings in an existing CloudFormation template:

```bash
updateami.sh my_template.json
updateami.sh beta my_dev_template.json
```

---

Bulk replace AMI mappings in a template folder:

```bash
updateami.sh ./cf/templates/*.json
updateami.sh alpha ./cf/templates/*.json
```

---
