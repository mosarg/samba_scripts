use utf8;
package Db::Django::Result::ConfigurationProfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::ConfigurationProfile

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

=head1 TABLE: C<configuration_profile>

=cut

__PACKAGE__->table("configuration_profile");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 profileId

  accessor: 'profile_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 defaultPolicy_id

  accessor: 'default_policy_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 mainGroup_id

  accessor: 'main_group_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 backendId_id

  accessor: 'backend_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

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
  "profileId",
  {
    accessor          => "profile_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "defaultPolicy_id",
  {
    accessor       => "default_policy_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "mainGroup_id",
  {
    accessor       => "main_group_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "backendId_id",
  {
    accessor       => "backend_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</profileId>

=back

=cut

__PACKAGE__->set_primary_key("profileId");

=head1 UNIQUE CONSTRAINTS

=head2 C<configuration_profile_role_id_6f148cf782727591_uniq>

=over 4

=item * L</role_id>

=item * L</backendId_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "configuration_profile_role_id_6f148cf782727591_uniq",
  ["role_id", "backendId_id"],
);

=head1 RELATIONS

=head2 backend_id

Type: belongs_to

Related object: L<Db::Django::Result::BackendBackend>

=cut

__PACKAGE__->belongs_to(
  "backend_id",
  "Db::Django::Result::BackendBackend",
  { backendId => "backendId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 default_policy

Type: belongs_to

Related object: L<Db::Django::Result::AccountPolicy>

=cut

__PACKAGE__->belongs_to(
  "default_policy",
  "Db::Django::Result::AccountPolicy",
  { policyId => "defaultPolicy_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 main_group

Type: belongs_to

Related object: L<Db::Django::Result::GroupGroup>

=cut

__PACKAGE__->belongs_to(
  "main_group",
  "Db::Django::Result::GroupGroup",
  { groupId => "mainGroup_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 role

Type: belongs_to

Related object: L<Db::Django::Result::AllocationRole>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Db::Django::Result::AllocationRole",
  { roleId => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-25 21:53:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:K6kc3UmzjQclvOPqJM4rXg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
