# encoding: utf-8

##
#
# View the Git repository at https://github.com/meskyanichi/backup
# View the Wiki/Documentation at https://github.com/meskyanichi/backup/wiki
# View the issue log at https://github.com/meskyanichi/backup/issues
#
# To restore/decrypt:
# backup decrypt --encryptor openssl --salt true --base64 true --in <filename>.enc --out <filename>.tar

##
# Global Configuration
# Add more (or remove) global configuration below

 Backup::Storage::S3.defaults do |s3|
   s3.access_key_id     = "<%= scope.lookupvar('backups::aws_access_key') %>"
   s3.secret_access_key = "<%= scope.lookupvar('backups::aws_secret_key') %>"
   s3.region            = "<%= scope.lookupvar('backups::aws_region') %>"
   s3.bucket            = "<%= scope.lookupvar('bucket') %>"
   s3.keep              = 10
 end

 <% if scope.lookupvar('backups::password') != '' -%>
 Backup::Encryptor::OpenSSL.defaults do |encryption|
   encryption.password = "<%= scope.lookupvar('backups::password') %>"
   encryption.base64   = true
   encryption.salt     = true
 end
 <% end -%>

##
# Load all models from the models directory (after the above global configuration blocks)
Dir[File.join(File.dirname(Config.config_file), "models", "*.rb")].each do |model|
  instance_eval(File.read(model))
end
