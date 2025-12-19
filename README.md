# ez-configuration

Small collection of bootstrap assets that turn a vanilla Ubuntu host into a Salt
minion that reports to our lab master.

## Repo layout

- `ubuntu.yml` &mdash; cloud-init userdata that installs Ansible, clones this
  repo, and executes `saltminion.yml`.
- `saltminion.yml` &mdash; idempotent Ansible playbook that installs the Salt
  packages, drops the master configuration found in `conf/master.conf`, and
  ensures the minion service is ready to accept jobs.
- `inventory.ini` &mdash; simple inventory example for running the playbook
  remotely over SSH. Add or replace hosts as needed.
- `conf/master.conf` &mdash; Salt minion configuration snippet that points the
  worker at the correct master IP.

## Usage

### Bootstrapping a fresh VM

1. Launch an Ubuntu image that supports cloud-init.
2. Paste the contents of `ubuntu.yml` into the user-data field (or supply the
   file directly, depending on your platform).
3. When the instance finishes booting, it will clone this repo to
   `/opt/ez-configuration` and execute the Ansible playbook locally. No further
   action is required unless you want to override defaults such as the master IP
   address.

### Running the playbook manually

If you already have Ansible installed, you can run the playbook against a host
over SSH using the included inventory. Replace the host entry in
`inventory.ini` and run:

```sh
ansible-playbook -i inventory.ini saltminion.yml
```

To target localhost with no inventory file, run:

```sh
ansible-playbook saltminion.yml -i localhost, -c local
```

## Customization

- **Master IP**: Update `conf/master.conf` before running the playbook to point
  new minions at a different Salt master.
- **Extra configuration**: Extend `saltminion.yml` with additional tasks (e.g.
  keystore setup, custom grains) as required. The playbook is idempotent, so you
  can safely re-run it whenever configuration drifts.
- **Credentials**: Update `inventory.ini` with the correct SSH users or Ansible
  connection variables for your environment.
