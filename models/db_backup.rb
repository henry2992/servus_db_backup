# encoding: utf-8

##
# Backup Generated: db_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t db_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#

db_config = YAML.load_file('/home/deploy/servus/shared/config/database.yml')['production']
sc_config = YAML.load_file('/home/deploy/servus/shared/config/secrets.yml')['production']

Model.new(:db_backup, 'Database backup') do
  split_into_chunks_of 250
  compress_with Gzip
  
  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name           = db_config['database']
    db.username       = db_config['username']
    db.password       = db_config['password']
    db.host           = db_config['host']
    db.port           = db_config['port']
   
    # When dumping all databases, `skip_tables` and `only_tables` are ignored.
    db.additional_options = ["-xc", "-E=utf8"]
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  store_with S3 do |s3|
    s3.access_key_id = sc_config['S3_ACCESS_KEY_ID']
    s3.secret_access_key = sc_config['S3_SECRET_ACCESS_KEY']
    s3.region = sc_config['S3_REGION']
    s3.bucket = sc_config['S3_BUCKET']
    s3.path = sc_config['S3_PATH']
    s3.keep = Time.now - 2592000 # Remove all backups older than 1 month.
  end

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = "info@servus.com"
    mail.to                   = "info@servus.com"
  #  mail.cc                   = "cc@email.com"
  #  mail.bcc                  = "bcc@email.com"
  #  mail.reply_to             = "reply_to@email.com"
    mail.address              = "smtp.mailgun.org"
    mail.port                 = 587
    mail.domain               = sc_config['DOMAIN_MAILGUN']
    mail.user_name            = sc_config['USERNAME_MAILGUN']
    mail.password             = sc_config['PASSWORD_MAILGUN']
    mail.authentication       = "plain"
    mail.encryption           = :starttls
  end
end
