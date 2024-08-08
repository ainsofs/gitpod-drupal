#/bin/sh
set -e

# Create new drupal core code tree
mkdir drupal
# composer -n create-project drupal/recommended-project:${DRUPAL_CORE_VERSION} drupal
composer -n create-project --repository-url=https://github.com/ainsofs/drupal-project/tree/10.3-ainsofs:${DRUPAL_CORE_VERSION} drupal
cd drupal

# Add essential contirbute modules
composer -n require drush/drush
composer -n require 'drupal/project_browser:^1.0@beta'
composer -n require 'ainsofs/drupal-base'

# Add developer modules
composer -n require drupal/twig_debugger --dev
composer -n require drupal/devel --dev
composer -n require drupal/coder --dev
composer -n require drupal/webprofiler --dev
composer -n install

# Setup the phpcs standard
vendor/bin/phpcs --config-set installed_paths $(realpath vendor/drupal/coder/coder_sniffer/)
vendor/bin/phpcs --config-set default_standard Drupal,DrupalPractice

# Install Drupal
vendor/bin/drush -y site:install \
  minimal \
  --site-name="gitpod-drupal" \
  --account-name="admin" \
  --account-pass="$(openssl rand -base64 16)" \
  --db-url=sqlite://sites/default/files/.ht.sqlite

# Install recipe
php web/scripts/drupal recipes recipes/contrib/drupal-base

# Enable themes and modules
# vendor/bin/drush -y en project_browser

# Install aliases
curl -L https://gist.github.com/ainsofs/ba947741b230606be5d2f4aad6faf7bf/raw -o .bash_aliases
source .bash_aliases
