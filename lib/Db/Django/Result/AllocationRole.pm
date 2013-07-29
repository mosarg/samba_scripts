use utf8;
package Db::Django::Result::AllocationRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AllocationRole

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

=head1 TABLE: C<allocation_role>

=cut

__PACKAGE__->table("allocation_role");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 roleId

  accessor: 'role_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 role

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 ou

  data_type: 'varchar'
  is_nullable: 0
  size: 45

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
  "roleId",
  {
    accessor          => "role_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "role",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "ou",
  { data_type => "varchar", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</roleId>

=back

=cut

__PACKAGE__->set_primary_key("roleId");

=head1 UNIQUE CONSTRAINTS

=head2 C<role>

=over 4

=item * L</role>

=back

=cut

__PACKAGE__->add_unique_constraint("role", ["role"]);

=head1 RELATIONS

=head2 allocation_allocations

Type: has_many

Related object: L<Db::Django::Result::AllocationAllocation>

=cut

__PACKAGE__->has_many(
  "allocation_allocations",
  "Db::Django::Result::AllocationAllocation",
  { "foreign.roleId_id" => "self.roleId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 configuration_profiles

Type: has_many

Related object: L<Db::Django::Result::ConfigurationProfile>

=cut

__PACKAGE__->has_many(
  "configuration_profiles",
  "Db::Django::Result::ConfigurationProfile",
  { "foreign.role_id" => "self.roleId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-28 23:39:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ps4KB0CEvgZPnro/evB04Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
