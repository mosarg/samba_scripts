use utf8;
package Db::Django::Result::AllocationAllocation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Db::Django::Result::AllocationAllocation

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

=head1 TABLE: C<allocation_allocation>

=cut

__PACKAGE__->table("allocation_allocation");

=head1 ACCESSORS

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 allocationId

  accessor: 'allocation_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 yearId_id

  accessor: 'year_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 userId_id

  accessor: 'user_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 roleId_id

  accessor: 'role_id_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ou

  data_type: 'varchar'
  is_nullable: 0
  size: 50

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
  "allocationId",
  {
    accessor          => "allocation_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "yearId_id",
  {
    accessor       => "year_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "userId_id",
  {
    accessor       => "user_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "roleId_id",
  {
    accessor       => "role_id_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "ou",
  { data_type => "varchar", is_nullable => 0, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</allocationId>

=back

=cut

__PACKAGE__->set_primary_key("allocationId");

=head1 UNIQUE CONSTRAINTS

=head2 C<yearId_id>

=over 4

=item * L</yearId_id>

=item * L</userId_id>

=back

=cut

__PACKAGE__->add_unique_constraint("yearId_id", ["yearId_id", "userId_id"]);

=head1 RELATIONS

=head2 allocation_ataallocation

Type: might_have

Related object: L<Db::Django::Result::AllocationAtaallocation>

=cut

__PACKAGE__->might_have(
  "allocation_ataallocation",
  "Db::Django::Result::AllocationAtaallocation",
  { "foreign.ataAllocationId_id" => "self.allocationId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 allocation_studentallocation

Type: might_have

Related object: L<Db::Django::Result::AllocationStudentallocation>

=cut

__PACKAGE__->might_have(
  "allocation_studentallocation",
  "Db::Django::Result::AllocationStudentallocation",
  { "foreign.studentAllocationId_id" => "self.allocationId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 allocation_teacherallocations

Type: has_many

Related object: L<Db::Django::Result::AllocationTeacherallocation>

=cut

__PACKAGE__->has_many(
  "allocation_teacherallocations",
  "Db::Django::Result::AllocationTeacherallocation",
  { "foreign.allocationId_id" => "self.allocationId" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 role_id

Type: belongs_to

Related object: L<Db::Django::Result::AllocationRole>

=cut

__PACKAGE__->belongs_to(
  "role_id",
  "Db::Django::Result::AllocationRole",
  { roleId => "roleId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user_id

Type: belongs_to

Related object: L<Db::Django::Result::SysuserSysuser>

=cut

__PACKAGE__->belongs_to(
  "user_id",
  "Db::Django::Result::SysuserSysuser",
  { userId => "userId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 year_id

Type: belongs_to

Related object: L<Db::Django::Result::AllocationSchoolyear>

=cut

__PACKAGE__->belongs_to(
  "year_id",
  "Db::Django::Result::AllocationSchoolyear",
  { schoolYearId => "yearId_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-07-24 21:51:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BdcyclW1gUmkH7LmC5i0Cw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
