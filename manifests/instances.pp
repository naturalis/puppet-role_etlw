# Create all virtual hosts from hiera
class role_etlw::instances (
    $instances = undef,
)
{
  create_resources('apache::vhost', $instances)
}
