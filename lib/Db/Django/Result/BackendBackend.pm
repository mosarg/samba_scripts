use utf8;
package Db::Django::Result::BackendBackend;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::BackendBackend

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<backend_backend>

=cut

__PACKAGE__->table("backend_backend");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 backendId

  accessor: 'backend_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 kind

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 1000

=head2 serverIp

  accessor: 'server_ip'
  data_type: 'char'
  is_nullable: 0
  size: 39

=head2 serverFqdn

  accessor: 'server_fqdn'
  data_type: 'varchar'
  is_nullable: 0
  size: 200

=cut

__PACKAGE__->add_columns(
  "created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "modified",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "backendId",
  {
    accessor          => "backend_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "kind",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 1000 },
  "serverIp",
  { accessor => "server_ip", data_type => "char", is_nullable => 0, size => 39 },
  "serverFqdn",
  {
    accessor => "server_fqdn",
    data_type => "varchar",
    is_nullable => 0,
    size => 200,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</backendId>

=back

=cut

__PACKAGE__->set_primary_key("backendId");

=head1 UNIQUE CONSTRAINTS

=head2 C<kind>

=over 4

=item * L</kind>

=back

=cut

__PACKAGE__->add_unique_constraint("kind", ["kind"]);

=head1 RELATIONS

=head2 account_accounts

Type: has_many

Related object: L<Db::Django::Result::AccountAccount>

=cut

__PACKAGE__->has_many(
  "account_accounts",
  "Db::Django::Result::AccountAccount",
  { "foreign.backendId_id" => "self.backendId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 account_policies

Type: has_many

Related object: L<Db::Django::Result::AccountPolicy>

=cut

__PACKAGE__->has_many(
  "account_policies",
  "Db::Django::Result::AccountPolicy",
  { "foreign.backendId_id" => "self.backendId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 configuration_profiles

Type: has_many

Related object: L<Db::Django::Result::ConfigurationProfile>

=cut

__PACKAGE__->has_many(
  "configuration_profiles",
  "Db::Django::Result::ConfigurationProfile",
  { "foreign.backendId_id" => "self.backendId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-25 21:49:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LA+Fb2tci4Y0zxlxRLZAcQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
