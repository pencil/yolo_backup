# yolo_backup

yolo_backup allows you to create incremental backups of multiple servers using rsync over SSH. You can specify which backups to keep (daily, weekly, monthly, …) on a per-server basis.

## Setup

### Configuration

yolo_backup automatically loads `/etc/yolo_backup.yml`. If you would like to use a different path, use the `--config` parameter.

Take a look at the [example configuration](docs/configuration_example.yml) to see what's possible.
